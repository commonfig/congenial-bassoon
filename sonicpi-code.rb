##|________________________________________EXTERNAL_SAMPLES & BPM______________________________________________________

use_bpm 74

phone_ring = "/Users/JQ/Desktop/ncbisequences/phonering.wav"

convo = "/Users/JQ/Desktop/ncbisequences/shortintro.mp3"

ending = "/Users/JQ/Desktop/ncbisequences/ending.wav"

##|_________________________________________DEFINED_FUNCTIONS__________________________________________________________

define :intro_phone_ring do |loop = 1|
  with_fx :distortion, mix: 0.9, amp: 0.8 do
    loop.times do
      sample phone_ring, start: 0, finish: 0.05
      sleep sample_duration(phone_ring, start: 0, finish: 0.05)
    end
  end
end

define :intro_part_1 do
  in_thread do
    with_fx :distortion, mix: 0.4, amp: 0.5 do
      with_fx :ring_mod, mix: 0.2 do
        with_fx :krush, mix: 0.1, cutoff: rrand_i(60,90) do
          with_fx :rlpf, cutoff: rrand_i(90,120) do
            bg = sample convo, start: 0.05, finish: 0.5, amp: 0.8, rate: 1.05
            
            120.times do
              amp_vals = line(0.1, 0.5, steps:120, inclusive: true).reverse
              control bg, amp: amp_vals.tick,
                amp_slide: 1
              sleep 1
            end
          end
        end
      end
    end
  end
end


define :intro_part_2 do | seed = 111, amp_val |
  with_fx :distortion, mix: 0.4, amp: 0.8 do
    with_fx :ring_mod, mix: 0.2 do
      
      in_thread do
        use_random_seed seed
        115.times do
          with_fx :krush, mix: 0.1, cutoff: rrand(60,90) do
            with_fx :rlpf, cutoff: rrand(90,120) do
              
              slice_divs = [8, 16, 32].choose
              puts "Current slice_divs: " + slice_divs.to_s #remove
              intro_dur = sample_duration convo, num_slices: slice_divs,
                slice: Random.rand(1...slice_divs)
              i = Random.rand(1...slice_divs)
              sample convo, num_slices: slice_divs, slice: i, amp: amp_val.tick(:amp)
              sleep intro_dur
            end
          end
        end
      end
    end
  end
end

define :part_a1 do |loops = 4, seed = 0, amp_offset = 0.0|
  in_thread do
    with_fx :ping_pong, feedback: 0.01,
      max_phase: 1,
      mix: (line 0.1, 1, steps: 128).tick,
    pan_start: rrand(0.2,0.4) do
      
      use_random_source :light_pink
      notes = (scale :E3, :blues_minor, num_octaves: 3)
      s = seed
      loops.times do
        use_random_seed s
        16.times do
          if rand > 0.5
            
            n = notes.choose
            p = (line -0.7, 0.7, steps: 64)
            amp = rand(0.2) * amp_offset
            
            synth :beep, note: n, release: 1/4.0, amp: amp*0.5, pan: p.tick(:synth_tick)
            synth :sc808_claves, note: n-12, release: 1/4.0, amp: amp*0.1, pan: 0
            ##| synth :sc808_claves, note: n-12, release: 1/3.0, amp: amp*0.5, pan: rand_look-0.5
            synth :pretty_bell, note: n, release: 1/2.0, amp: amp*0.5, pan: p.tick(:synth_tick)
          end
          sleep 1/4.0
        end
        s += 1
        s = ((s-seed) % 4)+seed
      end
    end
  end
  sleep loops*4
end


define :part_a2 do |loops = 4, seed = 0, amp_offset = 0.3|
  amp_arp = amp_offset
  wide = 0.4
  in_thread do
    use_random_source :light_pink
    chords = [(chord :E3, :m7, num_octaves: 2),
              (chord :F3, :M7, num_octaves: 2),
              (chord :G3, :M7, num_octaves: 2),
              (chord :A3, :m7, num_octaves: 2),
              (chord :B3, :m7, num_octaves: 2),
              (chord :C4, :M7, num_octaves: 2),
              (chord :D4, :m7, num_octaves: 2)]
    s = seed
    
    with_fx :reverb, room: 1, mix: 0.5 do
      (loops/4.0).times do
        use_random_seed s
        
        4.times do
          ch = chords.choose #choosing random chords
          
          # arpeggio
          5.times do
            n = ch.tick (:chord_tick)
            synth :piano, note: n, release: 4, amp: amp_arp, pan: 0-(wide/2.0), sustain: 0.4
            synth :piano, note: n-12, release: 4, amp: amp_arp * 0.2, pan: wide/2.0, sustain: 0.4
            sleep 0.1
          end
          
          n = ch.tick (:chord_tick)
          synth :piano, note: n, release: 4, amp: amp_arp, pan: 0-(wide/2.0), sustain: 0.4
          synth :piano, note: n-12, release: 4, amp: amp_arp * 0.2, pan: wide/2.0, sustain: 0.4
          sleep 3.5
        end
      end
    end
  end
  sleep loops*4
end


define :kick_1 do | string, odds |
  
  define :random_pattern do |pattern|
    pattern = pattern.chars.map { |char| char == "-" && rand < odds ? "x" : char }.join
  end
  
  define :pattern do |pattern|
    return pattern.ring.tick(:pattern_tick) == "x"
  end
  
  in_thread do
    initial = string # "----------------"
    randomized = random_pattern initial
    puts randomized
    clip = :drum_bass_soft
    16.times do
      a = line(0.2,0.6, steps:8, inclusive: true).tick
      sample clip, amp: a, cutoff: 120 if pattern randomized
      sleep 0.25
    end
  end
end

define :part_a3 do |note = :A4, co=100, res=0.9, amp=0.2, seed|
  with_fx :reverb, mix: 0.2, room: 0.7, damp: 0.3 do
    use_random_seed seed
    10.times do
      play chord(note, :minor).choose,
        res: res, cutoff: rrand(co - 20, co + 20),
        amp: 0.5 * amp, attack: 0,
        release: rrand(0.5, 1.5), pan: rrand(-0.7, 0.7)
      sleep stretch(0.25, 1, 0.5, 3, 1, 2).to_a.shuffle.choose
      ##| sleep [0.25, 0.5, 0.5, 0.5, 1, 1].choose
    end
  end
end

define :ending_ring do |loop = 1, amp|
  with_fx :distortion, mix: 0.7, amp: amp do
    sample ending
    sleep sample_duration(ending)
  end
end

##|_________________________________________SEEDS_SEEDS_&_SEEDS__________________________________________________________

seed_0 = 111
seed_1 = 1337
seed_2 = 1299
seed_3 = 1400

##|_________________________________________THE_OVERALL_PIECE__________________________________________________________

value = line(0.1, 0.4, steps:48, inclusive: true)

intro_phone_ring # ring ring
intro_part_1     # japanese newslady --> introduction
sleep 8


intro_part_2 seed_0, value

in_thread do    # generative beat melody
  8.times do
    part_a1 4, [seed_1, seed_2, seed_1].tick, line(0.0,1.4, steps:8, inclusive: true).tick
    seed_1 += 2
    seed_2 += 2     # seed values add by 2 for each loop
  end
end

in_thread do
  sleep 16
  7.times do                # generative piano chords from a defined list
    part_a2  4,  0, 0.1     #seed = 0
  end
end

in_thread do
  sleep 24
  21.times do
    kick_1 "----------------", 0.25    # generative kick drum beat using randomly-generated 16-beat patterns, string can be altered to be longer or shorter
    sleep 5
  end
end

in_thread do
  sleep 48
  10.times do   #  another bit to make the piece polyrhythmic
    part_a3 :A3, 100, 0.9, 0.2, seed_3
    seed_3 += 200
  end
end

in_thread do # ending ring that uses a clip of a cut phone call to complement the intro
  sleep 129
  ending_ring 1, 0.15
end
