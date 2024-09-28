BASIC SID player v1.0 by Zirias

This player installs a simple BASIC extension for doing some music from BASIC.
The following commands are added:

  @i<n>,<a>,<d>,<s>,<r>,<w>,<p>,<l>[,<o>...] defines an instrument.
    <n>: instrument number (identifier)
    <a>: attack (0-15)
    <d>: decay (0-15)
    <s>: sustain (0-15)
    <r>: release (0-15)
    <w>: wave (129: noise, 65: pulse, 33: sawtooth, 17: triangle)
    <p>: pulse width (if wave is pulse), [-128, 127], 0 is equal length
    <l>: length of the accord sequence for arpeggio (0 for no arpeggio)
    <o>: offset from base note in arpeggio

  @t<n>,"<pat>" defines a pattern.
    <n>: pattern number (identifier)
    "<pat>": notes/rests in the following format:

      <i>[L]{A-G}[#|&]<o><d>: A note played with instrument number #<i>, A to
      G is the name of the note, # is a half-tone higher, & is a half-tone
      lower. <o> is the octave number (0-5) and <d> is the duration of the
      note. If the note name is preceeded by an L, this means "legato", so the
      pitch is changed without restarting the note.
      <i> and <d> can be larger as 9, but they must only occupy a single
      character, so for numbers larger than 9, the following characters in the
      PETSCII table are used. Therefore, e.g. ':' means 10.

      R<d>: A rest of duration <d>.

  @q<n>[,<t>...] defines a sequence for one of the three SID channels.
    <n>: SID channel (1-3)
    <t>: pattern number to play or jump position + 128 (so, 128 means jump to
    first entry in sequence, 129 means jump to second entry in sequence)

  @p<s> starts playing the song.
    <s>: playing speed, a unit in the patterns takes exactly <s> VIC-II
    frames.

  @x unloads the extension; after that command, all @-commands won't work any
  more.

