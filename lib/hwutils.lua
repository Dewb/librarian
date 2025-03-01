-- librarian/hwutils

local hwutils = {}


-- ------------------------------------------------------------------------
-- deps

local paramutils = include('librarian/lib/paramutils')
local midiutil = include('librarian/lib/midiutil')
local nbutils = include('librarian/lib/nbutils')


-- ------------------------------------------------------------------------

function hwutils.hw_from_static(t, id, count, midi_device, ch, nb)
  -- reveiw: copy table?
  local hw = t

  if not hw.display_name then
    hw.display_name = hw.kind
  end

  if not hw.shorthand then
    hw.shorthand = hw.kind
  end

  if not hw.ch then
    hw.ch = 1
  end

  -- had default hw device name, typically USB midi devices
  if hw.midi_device and midi_device == midiutil.MIDI_DEV_ALL then
    -- pass
  else
    hw.midi_device = midi_device
  end

  hw.id = id
  hw.fqid = hw.shorthand.."_"..id
  if count > 1 then
    hw.display_name = hw.display_name.." #"..id
  end

  if hw.plays_notes then
    hw.nb = true
    if nb ~= nil and not nb then
      hw.nb = false
    end
  end

  hw.param_props = {}
  hw.param_list = {}
  for _, p in pairs(hw.params) do
    hw.param_props[p.name] = p
    table.insert(hw.param_list, p.name)
  end

  function hw:get_nb_params()
    local count = #self.params
    if self.pgm_count or self.pgm_list then
      count = count + 1
    end
    return count
  end

  function hw:register_params()
    local supports_pgm_change = false
    if self.pgm_list then
      params:add_option(self.fqid .. '_pgm', "Program", self.pgm_list)
      supports_pgm_change = true
    elseif self.pgm_count then
      params:add{ type = "number", id = self.fqid .. '_pgm', name = "Program",
                  min = 1, max = self.pgm_count }
      supports_pgm_change = true
    end
    if supports_pgm_change then
      params:set_action(self.fqid .. '_pgm',
                        function(pgm_id)
                          midiutil.send_pgm_change(self.midi_device, self.ch, pgm)
                          self.pgm = pgm
      end)
    end

    paramutils.add_params(hw, self.param_props, self.param_list)
  end

  function hw:register_nb_players()
    nbutils.register_player(self)
  end

  return hw
end


-- ------------------------------------------------------------------------

return hwutils
