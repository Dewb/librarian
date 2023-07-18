-- librarian/midiutil

local midiutil = {}


-- ------------------------------------------------------------------------
-- consts

local DEVICE_ALL = "ALL"


-- ------------------------------------------------------------------------
-- send

function midiutil.send_msg(devname, msg)
  local data = midi.to_data(msg)
  local had_effect = false

  for _, dev in pairs(midi.devices) do
    if dev.port ~= nil and dev.name ~= 'virtual' then
      if devname == MIDI_DEV_ALL or devname == dev.name then
        midi.vports[dev.port]:send(data)
        had_effect = true
        if devname ~= MIDI_DEV_ALL then
          break
        end
      end
    end
  end

  return had_effect
end

function midiutil.send_cc(midi_device, ch, cc, val)
  local msg = {
    type = 'cc',
    cc = cc,
    val = val,
    ch = ch,
  }
  midiutil.send_msg(midi_device, msg)
end

function midiutil.send_nrpn(midi_device, ch, msb_cc, lsb_cc, val)
  -- NB:
  -- 16256 = 1111111 0000000
  -- 127   = 0000000 1111111

  local msb = (val & 16256) >> 7
  local lsb = val & 127

  print(msb .. " -> MSB CC " .. msb_cc)
  print(lsb .. " -> LSB CC " .. lsb_cc)

  -- 64 on cc 63

  midiutil.send_cc(midi_device, ch, msb_cc, msb)
  midiutil.send_cc(midi_device, ch, lsb_cc, lsb)
end

function midiutil.send_pgm_change(midi_device, ch, pgm)
  local msg = {
      type = "program_change",
      val = pgm,
      ch = ch,
    }
  midiutil.send_msg(midi_device, msg)
end


-- ------------------------------------------------------------------------

return midiutil
