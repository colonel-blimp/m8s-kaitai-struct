meta:
  id: 'm8s_2_6_0'
  file-extension:
    - m8s
    - m8i
    - m8t
    - m8n
  title: 'M8 Song/Instrument/Theme/Scale file (Firmware 2.6.0)'
  license: GPL-3.0-or-later
  bit-endian: le
  endian: le
  encoding: utf-8

doc: |
  M8 Song/Instrument/Theme/Scale file formats (WIP)
  
  Developed against M8 firmware version 2.6.0
  (Handles other firmware versions so far, but no guarantees)
doc-ref: https://gist.github.com/ftsf/223b0fc761339b3c23dda7dd891514d9

seq:
  - id: header
    type: m8_header
  - id: body
    type:
      switch-on: header.file_type
      cases:
        'm8_filetype::song_file': m8_song
        'm8_filetype::instrument_file': m8_instrument
        'm8_filetype::theme_file': m8_theme
        'm8_filetype::scale_file': m8_scale


types:
  m8_header:
    seq:
    - id: magic
      contents:
        - 'M8VERSION'
        - 0x00
      doc: magic number
    - id: version_z
      type: b4
    - id: version_y
      type: b4
    - id: version_x
      type: b4
    - id: file_type
      type: u2
      enum: m8_filetype

  m8_song:
    seq:
      - id: directory
        size: 128
        type: strz
      - id: transpose
        type: u1
      - id: tempo
        type: f4
      - id: quantize
        type: u1
      - id: name
        size: 12
        type: strz
      - id: midi_settings
        type: midi_settings
      - size: 19 # all 00s
      - id: mixer_settings
        type: mixer_settings
      - size: 5 # TODO what is this?  It has data in it         
      - id: grooves
        type: groove
        repeat: expr
        repeat-expr: 32
      - id: song_data
        type: song_row
        repeat: expr
        repeat-expr: 256
      - id: phrases
        type: phrase
        repeat: expr
        repeat-expr: 255
      - id: chains
        type: chain
        repeat: expr
        repeat-expr: 255
      - id: tables
        type: table
        repeat: expr
        repeat-expr: 256
      - id: instruments
        type: instrument(27)
        repeat: expr
        repeat-expr: 128
        size: 215 # 215 * 128 = 27520
      - size: 3 
        id: mystery # TODO what is this?
      - id: global_fx
        type: global_fx
      - size: 1191 # TODO mystery data + probable padding
        id: mystery2
      - id: scales
        type: scales
        repeat: expr
        repeat-expr: 16
        size: 42

  scales:
    seq:
      - id: enabled_notes
        type: b1
        repeat: expr
        repeat-expr: 12
      - id: unused_bits
        type: b4
      - id: notes
        type: u1
        repeat: expr
        repeat-expr: 12
      - id: offsets
        type: u1
        repeat: expr
        repeat-expr: 12        
      - id: name
        size: 16
        type: str
        terminator: 0xff

        
  global_fx:
    seq:
      - id: chorus_mod_depth
        type: u1
      - id: chorus_mod_freq
        type: u1        
      - id: chorus_width
        type: u1
      - id: chorus_reverb_send
        type: u1
      - size: 3  # TODO verify what these are
        id: mystery
      - id: delay_filter_hp # TODO this might be 3 bytes earlier
        type: u1 
      - id: delay_filter_lp
        type: u1        
      - id: delay_time_l
        type: u1         
      - id: delay_time_r
        type: u1
      - id: delay_feedback
        type: u1        
      - id: delay_width
        type: u1
      - id: delay_reverb_send
        type: u1
      - size: 1
      - id: reverb_filter_hp
        type: u1 
      - id: reverb_filter_lp 
        type: u1        
      - id: reverb_size
        type: u1         
      - id: reverb_decay
        type: u1
      - id: reverb_mod_depth
        type: u1        
      - id: reverb_mod_freq
        type: u1
      - id: reverb_width
        type: u1
  instrument:
    params:
      - id: unknown_data_len
        type: u1
    seq:
      - id: type
        type: u1
        enum: instrument_type
      - id: name
        type: strz
        size: 12
      - id: transpose
        type: u1
      - id: table_tic_rate
        type: u1
      - id: type_data
        type:
          switch-on: type
          cases:
            'instrument_type::wavsynth': wavsynth_data
            'instrument_type::macrosyn': macrosyn_data
            'instrument_type::sample':   sample_data
            'instrument_type::midiout': midi_instrument_data
            'instrument_type::fmsynth': fm_data
            'instrument_type::none': no_instrument_data
      - id: common_data
        type: common_instrument_data
      - size: unknown_data_len # TODO: what is this?  27 (song) or 25 (inst)
      - id: sample_path
        size: 127
        type: strz
        if: type == instrument_type::sample



  common_instrument_data:
    seq:
      - id: filter
        type: u1
      - id: cutoff
        type: u1
      - id: res
        type: u1
      - id: amp
        type: u1
      - id: lim
        type: u1
      - id: pan
        type: u1
      - id: dry
        type: u1
      - id: cho
        type: u1
      - id: del
        type: u1
      - id: rev
        type: u1        
      - size: 2 # TODO what is this?
      - id: envelopes
        type: envelope
        repeat: expr
        repeat-expr: 2
      - id: lfos
        type: lfo
        repeat: expr
        repeat-expr: 2 # TODO: version check [x2 LFOs added in 1.4.0]
  lfo:
    seq:
      - id: shape
        type: u1
      - id: dest
        type: u1
      - id: trigger_mode
        type: u1
      - id: freq
        type: u1
      - id: amount
        type: u1
      - id: retrigger
        type: u1
  
  envelope:
    seq:
      - id: dest
        type: u1
      - id: amount
        type: u1
      - id: attack
        type: u1
      - id: hold
        type: u1
      - id: decay
        type: u1
      - id: retrigger
        type: u1
        
  fm_data: # todo 
    seq:
      - id: volume
        type: u1
      - id: pitch
        type: u1
      - id: finetune
        type: u1    
      - id: algo
        type: u1
      - id: wave  # TODO: FM wave type added in 1.4.0
        type: u1
        repeat: expr
        repeat-expr: 4
      - id: ratios
        type: fm_op_ratio
        repeat: expr
        repeat-expr: 4
      - id: level
        type: fm_op_level
        repeat: expr
        repeat-expr: 4
      - id: mod_a
        type: u1
        repeat: expr
        repeat-expr: 4
      - id: mod_b
        type: u1
        repeat: expr
        repeat-expr: 4  
      - id: mods
        type: u1
        repeat: expr
        repeat-expr: 4        
        
  fm_op_ratio:
    seq:
      - id: ratio
        type: u1
      - id: ratio_fine
        type: u1
  fm_op_level:
    seq:
      - id: level
        type: u1
      - id: feedback
        type: u1

  sample_data:
    seq:
      - id: pitch
        type: u1
      - id: finetune
        type: u1    
      - id: play_mode
        type: u1
      - id: slices
        type: u1
      - id: start
        type: u1
      - id: loop_start
        type: u1
      - id: length
        type: u1
      - id: degrade
        type: u1
  
  macrosyn_data:
    seq:
      - id: volume
        type: u1
      - id: pitch
        type: u1
      - id: finetune
        type: u1    
      - id: shape
        type: u1
      - id: timbre
        type: u1
      - id: color
        type: u1
      - id: degrade
        type: u1
      - id: redux
        type: u1
 
  wavsynth_data:
    seq:
      - id: volume
        type: u1
      - id: pitch
        type: u1
      - id: finetune
        type: u1    
      - id: shape
        type: u1
      - id: size
        type: u1
      - id: mult
        type: u1
      - id: warp
        type: u1
      - id: mirror
        type: u1
      - id: none
        size: 1


  midi_instrument_data:
    seq:
      - id: port
        type: u1
      - id: channel
        type: u1
      - id: bank_lsb
        type: u1
      - id: program
        type: u1
      - id: unknown
        size: 3
      - id: cca
        type: u1
      - id: cca_default
        type: u1
      - id: ccb
        type: u1
      - id: ccb_default
        type: u1
      - id: ccc
        type: u1
      - id: ccc_default
        type: u1
      - id: ccd
        type: u1
      - id: ccd_default
        type: u1
      - id: cce
        type: u1
      - id: cce_default
        type: u1
      - id: ccf
        type: u1
      - id: ccf_default
        type: u1
      - id: ccg
        type: u1
      - id: ccg_default
        type: u1
      - id: cch
        type: u1
      - id: cch_default
        type: u1
      - id: cci
        type: u1
      - id: cci_default
        type: u1
      - id: ccj
        type: u1
      - id: ccj_default
        type: u1        
      - id: padding
        size: 8
      

        
  no_instrument_data:
    seq:
      - id: padding
        size: 11
  
  table:
    seq:
      - id: rows
        type: table_row
        repeat: expr
        repeat-expr: 16       

  table_row:
    seq:
      - id: note_offset
        type: u1
      - id: vol
        type: u1
      - id: fx1_cmd
        type: u1
        enum: fx_common
      - id: fx1_value
        type: u1
      - id: fx2_cmd
        type: u1
        enum: fx_common
      - id: fx2_value
        type: u1
      - id: fx3_cmd
        type: u1
        enum: fx_common
      - id: fx3_value
        type: u1 
        
  chain:
    seq:
      - id: rows
        type: chain_row
        repeat: expr
        repeat-expr: 16
  
  chain_row:
    seq:
      - id: phrase
        type: u1
      - id: transpose
        type: u1
        
        
  phrase:
    seq:
      - id: rows
        type: phrase_row
        repeat: expr
        repeat-expr: 16
        
  phrase_row:
    seq:
      - id: note
        type: u1
      - id: vol
        type: u1
      - id: instrument
        type: u1
      - id: fx1_cmd
        type: u1
        enum: fx_common
      - id: fx1_value
        type: u1
      - id: fx2_cmd
        type: u1
        enum: fx_common
      - id: fx2_value
        type: u1
      - id: fx3_cmd
        type: u1
        enum: fx_common
      - id: fx3_value
        type: u1        
  song_row:
    seq:
      - id: column
        type: u1
        repeat: expr
        repeat-expr: 8

  groove:
    seq:
      - id: steps
        type: u1
        repeat: expr
        repeat-expr: 16

  midi_settings:
    seq:
      - id: recieve_sync
        type: u1
        enum: on_off
      - id: receive_transport
        type: u1
        enum: on_off
      - id: send_sync
        type: u1
        enum: on_off
      - id: send_transport
        type: u1
        enum: on_off
      - id: record_note_channel
        type: u1
      - id: record_velocity
        type: u1
        enum: on_off
      - id: record_delay_kill
        type: u1
        enum: on_off
      - id: control_map_channel
        type: u1
        enum: control_map_channel
      - id: song_row_cue_channel
        type: u1
      - id: track_input_channels
        type: u1
        repeat: expr
        repeat-expr: 8
      - id: track_input_instruments
        type: u1
        repeat: expr
        repeat-expr: 8
      - id: track_input_program_change
        type: u1
      - id: track_input_mode
        type: u1
        enum: midi_track_input_mode
  
  mixer_settings:
    seq:
      - id: main_volume
        type: u1
      - id: limit
        type: u1
      - id: track_volumes
        type: u1
        repeat: expr
        repeat-expr: 8
      - id: chorus_volume
        type: u1
      - id: delay_volume
        type: u1
      - id: reverb_volume
        type: u1
      - id: todo__wat1__input_usb_fx__wat2
        size: 12
      - id: djfilter
        type: u1
      - id: djf_peak
        type: u1


  m8_instrument:
    seq:
      - id: instrument
        type: instrument(25)
        size: 215
      - id: table
        type: table
      
        
  m8_theme:
      seq:
      - id: whatisthis
        type: b4
        
  m8_scale:
      seq:
      - id: what_is_this
        size: 26
      - id: name
        type: strz
      - id: what_is_this__finalbyte
        size: 1


enums:
  m8_filetype:
    0x0000: song_file
    0x1000: instrument_file
    0x2000: theme_file
    0x3000: scale_file
  midi_track_input_mode:
    0x0: mono
    0x1: legato
    0x2: poly
  on_off:
    0x0: off
    0x1: on
  control_map_channel:
    0x0: ch1
    0x1: ch2
    0x2: ch3
    0x3: ch4
    0x4: ch5
    0x5: ch6
    0x6: ch7
    0x7: ch8
    0x8: ch9
    0x9: ch10
    0xA: ch11
    0xB: ch12
    0xC: ch13
    0xD: ch14
    0xE: ch15
    0xF: ch16
    0x10: todo__notsure
    0x11: all
  instrument_type:
    0x00: wavsynth
    0x01: macrosyn
    0x02: sample
    0x03: midiout
    0x04: fmsynth
    0xFF: none
  fx_common: # TODO: validate these
    0x00: arp
    0x01: cha
    0x02: del
    0x03: grv
    0x04: hop
    0x05: kil
    0x06: ran
    0x07: ret
    0x08: rep
    0x09: nth
    0x0A: psl
    0x0b: pvb
    0x0C: pvx
    0x0D: sed
    0x0E: xx0
    0x0F: tbl
    0x10: tho
    0x11: xx5 # imp = tic 
    0x12: tpo
    0x13: xx1
    0x14: tic # imp = vmv
    0x15: xx2
    0x16: xcm
    0x17: xcf
    0x18: xcw
    0x19: xcr
    0x1A: xdt
    0x1B: xdf
    0x1C: xdw
    0x1D: xdr
    0x1E: xrs
    0x1F: xrd
    0x20: xrm
    0x21: xrf
    0x22: xrw
    0x23: xrz
    0x24: xx3
    0x25: vch
    0x26: vde
    0x27: vre
    0x28: vt1
    0x29: vt2
    0x2A: vt3
    0x2B: vt4
    0x2C: vt5
    0x2D: vt6
    0x2E: vt7
    0x2F: vt8
    0x30: xx4
    0x31: djf
    0x81: pit 
    0x82: fin
    0x83: osc
    0x84: siz # tbr
    0x85: mul # col
    0x89: cut
    0x8b: amp
    0x91: srv
  