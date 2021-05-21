
// NOTE: this first block loads SynthDefs and plays the first track all in one to avoid multiple evaluations
// Because I intend the other tracks to be fully modular and independant, one must evaluate every block for each other track
(
s.waitForBoot
{

// What follows is the form and implemenation for the first track and then the SynthDefs required for all the tracks:

// Track 1: TOWN THEME ("1-1"):

// FORM: (loop forever and fade out)
// Intro
// A (2x)
// B (2x)

// ******** Channel 1 Notes and Durations ***********

var c1phrase1_durs = Pseq([1,1.5,0.25,0.25,3.5,0.5,1,1,2]);

var c1phrase1_notes = Pseq([67,79,78,77,76,72,71,65,67]);

var c1phrase2_notes = Pseq([67,79,78,77,76,77,81,84,87,84,81,77]);

var c1phrase2_durs = Pseq([1,1.5,0.25,0.25,3.5,0.5,1,1,1,1,1,1]);

var c1phrase1 = Pbind(\instrument, "channel-1", \startNote, c1phrase1_notes, \endNote, c1phrase1_notes, \dur, c1phrase1_durs, \speed, 60/110);

var c1phrase2 = Pbind(\instrument, "channel-1", \startNote, c1phrase2_notes, \endNote, c1phrase2_notes, \dur, c1phrase2_durs,\speed, 60/110);

// B section:

var c1phrase3_notes = Pseq([76,Rest(),76,88,86,84,82,81,80,79,80,77,79,Rest(),77,80,84,87,84,79,77]);

var c1phrase3_durs = Pseq([2,2,2,1,1,1.5,0.25,0.25,2,2,1,1,2,6,2,1,1,1,1,1,1]);


var c1phrase3 = Pbind(\instrument, "channel-1", \startNote, c1phrase3_notes, \endNote, c1phrase3_notes, \dur, c1phrase3_durs,\speed, 60/110);
// ******** Channel 2 Notes and Durations ***********

var cmaj_arp = [64,60,59,55]; // channel two arpegiates different chords many times, here they are to avoid repetition
var fmin_arp = [63,60,56,53];
var gmin_arp = [70,69,65,62];
var c2phrase1_durs = Pseq(Array.fill(32,{0.5}));
var c2phrase1_notes = Pseq([64,60,59,55,64,60,59,55,64,60,59,55,64,60,59,55,65,62,60,57,65,62,60,57,67,65,64,60,67,65,64,60]);

var c2phrase2_durs = Pseq(Array.fill(32,{0.5}));
var c2phrase2_notes = Pseq([64,60,59,55,64,60,59,55,64,60,59,55,64,60,59,55,65,62,60,57,65,62,60,57,63,60,56,53,63,60,56,53]);

var c2bridge_notes = Pseq([64,60,59,55,64,60,59,55]);
var c2bridge_durs = Pseq(Array.fill(8,{0.5}));

var c2phrase1 = Pbind(\instrument, "channel-2", \note, c2phrase1_notes, \dur, c2phrase1_durs, \duty, 0.25, \amp, 0.08,\speed, 60/110);

var c2phrase2 = Pbind(\instrument, "channel-2", \note, c2phrase2_notes, \dur, c2phrase2_durs, \duty,0.25, \amp, 0.08,\speed, 60/110);

var c2bridge = Pbind(\instrument, "channel-2", \note, c2bridge_notes, \dur, c2bridge_durs, \duty,0.25, \amp, 0.08,\speed, 60/110); // this Pbind is one extra filler meaasure that goes in the middle of the phrase

// B section:

var c2phrase3_durs = Pseq(Array.fill(64,{0.5}));

var c2phrase3_notes = Pseq(cmaj_arp++cmaj_arp++cmaj_arp++cmaj_arp++fmin_arp++fmin_arp++fmin_arp++fmin_arp++gmin_arp++gmin_arp++gmin_arp++gmin_arp++fmin_arp++fmin_arp++fmin_arp++fmin_arp);


var c2phrase3 = Pbind(\instrument, "channel-2", \note, c2phrase3_notes, \dur, c2phrase3_durs, \duty, 0.25, \amp, 0.08,\speed, 60/110);
// ******** Channel 3 (bass) Notes and Durations ***********

var c3_durs = Pseq([1.5,0.5],50);
var bass_cmaj = [48,55,60,55]; // bass chord outlines
var bass_dmaj = [50,57,62,57];
var bass_fmaj = [53,60,65,60];

var c3phrase1_notes = Pseq(bass_cmaj++bass_cmaj++bass_dmaj++bass_fmaj++bass_cmaj++bass_cmaj++bass_cmaj++bass_dmaj++bass_fmaj);

var c3phrase1 = Pbind(\instrument, "channel-3", \note, c3phrase1_notes, \dur, c3_durs,\speed, 60/110);

// B section:

var bass_gmin = [55,62,67,62];
var c3phrase2_notes = Pseq(bass_cmaj++bass_cmaj++bass_fmaj++bass_fmaj++bass_gmin++bass_gmin++bass_fmaj++bass_fmaj);

var c3phrase2 = Pbind(\instrument, "channel-3", \note, c3phrase2_notes, \dur, c3_durs,\speed, 60/110);

// all voices assembled:
var a_section = Ptpar([7,c1phrase1,0,c2phrase1,0,c3phrase1, 16,c2bridge,23,c1phrase2, 20, c2phrase2]);

var b_section = Ptpar([0,c1phrase3,0,c2phrase3,0,c3phrase2],2);

var piece = PfadeOut(Pseq([a_section,b_section,a_section],2),145);

s.sync;


// first channel is a pulse wave that can also do frequency sweeps for effects (e.g frequency can change during sound)
// also had variable duration of notes and ability to support envelopes, articulations etc
SynthDef("channel-1", { |duty = 0.5, startNote = 69, endNote = 69, dur = 0.3, amp = 0.1, pan = 0, staccato=0, speed|
	var time = dur*speed; // use args to get correct env length for given tempo ('speed')
	var attack = 0.001;
	var decay = 0.03;
	var env = Env.linen(attack,time-attack-decay-staccato,decay);
	var freqSweep = Env.new([startNote.midicps,endNote.midicps],[dur]); // envelope that controls frequency
	// Use decimator to simulate 4 bit per channel sound
	var pulse = Decimator.ar(Pulse.ar(freqSweep.kr, width:duty),44100,4)*env.kr(2)*amp; // pulse wave, gameboy had duty values of either .125, .25, .5, .75
	var panning = Pan2.ar(pulse,pan);
	var out = Out.ar(0,panning);


}).add;


// channel 2 is very similar to channel 1 except it did not have a frequency sweep
SynthDef("channel-2", { |duty = 0.5, note=69, dur = 0.3, amp = 0.1, pan = 0, staccato=0, speed|
	var time = dur*speed;
	var attack = 0.001;
	var decay = 0.03;
	var env = Env.linen(attack,time-attack-decay-staccato,decay);
	var pulse = Decimator.ar(Pulse.ar(note.midicps, width:duty),44100,4)*env.kr(2)*amp; // pulse wave, gameboy had duty values of either .125, .25, .5, .75
	var panning = Pan2.ar(pulse,pan);
	var out = Out.ar(0,panning);

}).add;


// uses noise plus a HPF to simulate high hats/snare sound
SynthDef("noise-hh", { |amp = 0.1, cutoff = 2000, pan = 0|
	var env = Env.perc(0.01,releaseTime:0.3);
	var noise = WhiteNoise.ar().round(0.1)*env.kr(2)*amp;
	var filtered = HPF.ar(noise, cutoff);

	var panning = Pan2.ar(filtered,pan);
	var out = Out.ar(0,panning);

}).add;


// uses noise plus a LPF to simulate a bass or kick drum
SynthDef("noise-kick", { |amp = 0.1, cutoff = 2000, pan = 0|
	var env = Env.perc(0.01,releaseTime:0.3);
	var noise = WhiteNoise.ar().round(0.1)*env.kr(2)*amp;
	var filtered = LPF.ar(noise, cutoff);

	var panning = Pan2.ar(filtered,pan);
	var out = Out.ar(0,panning);

}).add;


// third non-noise channel in NES was triangle wave, in GBA it was general waveform (often used for basslines)
// On NES this channel had NO volume envelope, just on or off for some duration
SynthDef("channel-3", { |note=69, dur = 0.3, amp = 0.2, pan = 0,staccato=0,speed|
	var time = dur*speed;
	var attack = 0.001;
	var decay = 0.03;
	var env = Env.linen(attack,time-attack-decay-staccato,decay);
	var tri = Decimator.ar(LFTri.ar(note.midicps),44100,4)*env.kr(2)*amp; // triangle wave, gameboy had duty values of either .125, .25, .5, .75
	var panning = Pan2.ar(tri,pan);
	var out = Out.ar(0,panning);

}).add;

// an interesting historical anecdote is that it seems reverb was achieved by actually just using two tracks, with one delayed and softer
// it is done more idiomatically in SuperCollider here:
SynthDef(\delay, {|bus=0, delTime = 0.2,amp=0.4|
	var in = In.ar(bus, 2);
	var delay = CombN.ar(in, delaytime:delTime, mul:amp, decaytime:3);
	var out = Out.ar(0,delay);
}).add;

s.sync;

t = TempoClock.new(110/60);

piece.play(t);
}
)


// TRACK 2: ROUTE THEME ("1-2"):
(

// FORM (2x):
// Intro
// A (2x)
// B (2x)
// Α (2x)

// ******** Channel 1 (bass) Notes and Durations ***********

var c1intro_durs = Pseq([0.25,0.25,0.25,0.25,2]);

var c1intro_notes = Pseq([79,83,86,90,91]);

var c1intro = Pbind(\instrument, "channel-1", \startNote, c1intro_notes, \endNote, c1intro_notes, \dur, c1intro_durs, \pan, 1, \amp,0.05,\speed, 60/150);

var c1phrase1_notes =  Pseq([71,72,74,76,74,72,71,72,74,79,Rest(),71,72,74,76,74,72,81,79,78,76]);

var c1phrase1_durs = Pseq([0.5,0.5,0.5,1,0.5,1,0.5,0.5,0.5,1.5,1,0.5,0.5,0.5,1,0.5,1,0.5,0.5,0.5,2.5]);

var c1phrase1 = Pbind(\instrument, "channel-1", \startNote, c1phrase1_notes, \endNote, c1phrase1_notes, \dur, c1phrase1_durs, \staccato, -0.01,\speed, 60/150);

var c1phrase2_notes =  Pseq([71,72,74,76,74,72,72,74,76,79,78,76,74,76,78,79,86,84,83,81,79]);

var c1phrase2_durs = Pseq([0.5,0.5,0.5,1,0.5,1,0.5,0.5,0.5,1,0.5,1,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,2]);

var c1phrase2 = Pbind(\instrument, "channel-1", \startNote, c1phrase2_notes, \endNote, c1phrase2_notes, \dur, c1phrase2_durs, \staccato, -0.01, \speed, 60/150);

// B section:

var c1phrase3_notes =  Pseq([84,86,88,91,93,91,90,88,78,79,81,83,85,86,88]);

var c1phrase3_durs = Pseq([1.5,0.25,0.25,2,1.5,0.25,0.25,2,1.5,0.25,0.25,1.5,0.25,0.25,2]);

var c1phrase3 = Pbind(\instrument, "channel-1", \startNote, c1phrase3_notes, \endNote, c1phrase3_notes, \dur, c1phrase3_durs, \staccato, -0.01, \amp, 0.07, \speed, 60/150);

var c1phrase4_notes =  Pseq([86,88,90,93,100,98,97,95,88,90,91,93,95,97,98]);

var c1phrase4 = Pbind(\instrument, "channel-1", \startNote, c1phrase4_notes, \endNote, c1phrase4_notes, \dur, c1phrase3_durs, \staccato, -0.01, \amp, 0.07, \speed, 60/150);

// ******** Channel 2 Notes and Durations ***********


var c2intro_notes = Pseq([71,74,79,81,83]);

var c2intro_durs = Pseq([0.25,0.25,0.25,0.25,2]);

var c2intro = Pbind(\instrument, "channel-2", \note, c2intro_notes, \dur, c2intro_durs, \duty,0.25, \amp, 0.05, \pan, -1, \speed, 60/150);

var c2phrase1_notes =  Pseq([71,Rest(),71,76,Rest(),76,71,Rest(),71,76,Rest(),76,71,Rest(),71,76,Rest(),76,78,Rest(),78]);

var c2phrase1_durs = Pseq([1,0.5,2.5],7);

var c2phrase1 = Pbind(\instrument, "channel-2", \note, c2phrase1_notes, \dur, c2phrase1_durs, \amp, 0.03, \speed, 60/150);

var c2phrase2_notes =  Pseq([79,Rest(),79,78,76,78,76,74]);

var c2phrase2_durs = Pseq([1,1,1/3,1/3,1/3,1/3,1/3,1/3]);

var c2phrase2 = Pbind(\instrument, "channel-2", \note, c2phrase2_notes, \dur, c2phrase2_durs, \staccato, -0.03, \amp, 0.06, \speed, 60/150);

// B section:

var c2phrase3_notes =  Pseq([76,Rest(),76,73,Rest(),73,74,Rest(),74,73,Rest(),73,74,Rest(),74,76,Rest(),76,73,Rest(),73,74,Rest(),74]);

var c2phrase3_durs = Pseq([1,0.5,2.5],8);

var c2phrase3 = Pbind(\instrument, "channel-2", \note, c2phrase3_notes, \dur, c2phrase3_durs, \amp, 0.03, \speed, 60/150);


// ******** Channel 3 (bass) Notes and Durations ***********

var c3intro_notes = Pseq([50,62,50]);

var c3intro_durs = Pseq([0.5,0.5,0.5]);

var c3intro = Pbind(\instrument, "channel-3", \note, c3intro_notes, \dur, c3intro_durs, \amp, 0.1, \speed, 60/150);

var g_maj_bass = [55,Rest(),62,Rest(),57,59];
var c_maj_bass = [60,Rest(),67,Rest(),52,54];
var d_maj_bass = [50,Rest(),57,Rest(),57,59];
var c_into_d = [60,Rest(),67,Rest(),47,49];

var c3phrase1_notes = Pseq(g_maj_bass++c_maj_bass++g_maj_bass++c_maj_bass++g_maj_bass++c_into_d++d_maj_bass);

var c3phrase1_durs = Pseq([1,0.5,1,0.5,0.5,0.5],7);

var c3phrase1 = Pbind(\instrument, "channel-3", \note, c3phrase1_notes, \dur, c3phrase1_durs, \amp, 0.1, \speed, 60/150);

var c3phrase2_notes = Pseq([55,Rest(),67,50,62,50]);

var c3phrase2_durs = Pseq([1,0.5,1,0.5,0.5,0.5]);

var c3phrase2 = Pbind(\instrument, "channel-3", \note, c3phrase2_notes, \dur, c3phrase2_durs, \amp, 0.1, \speed, 60/150);

// B section:


var b_sec_c_maj = [48,43,48,43,48,43,48,43];
var b_sec_a_maj = [45,40,45,40,45,40,45,40];
var b_sec_d_maj = [50,45,50,45,50,45,50,45];
var b_sec_e_min = [52,47,52,47,52,47,52,47];

var c3phrase3_notes = Pseq(b_sec_c_maj++b_sec_a_maj++b_sec_d_maj++b_sec_a_maj++b_sec_d_maj++b_sec_e_min++b_sec_a_maj++b_sec_d_maj);

var c3phrase3_durs = Pseq([0.5],64);

var c3phrase3 = Pbind(\instrument, "channel-3", \note, c3phrase3_notes, \dur, c3phrase3_durs, \amp, 0.1, \speed, 60/150);



// ******** Channel 4 (noise) Notes and Durations ***********

var c4intro_durs = Pseq([1.5,1.5,0.5,0.5],8);

var c4phrase1 = Pbind(\instrument, "noise-hh", \dur, c4intro_durs, \amp, 0.05);

var c4phrase2_durs = Pseq([1],32);

var c4phrase2 = Pbind(\instrument, "noise-hh", \dur, c4phrase2_durs, \amp, 0.05);

// Intro all together:

var intro = Ptpar([0,c1intro,0, c2intro,3.5, c3intro]);

// A section unified:
var a_section = Ptpar([0,c1phrase1,0,c2phrase1,0,c3phrase1,0,c4phrase1,16, c1phrase2, 28, c3phrase2, 28,c2phrase2],2);

// B section unified:
var b_section = Ptpar([0,c1phrase3,0, c2phrase3, 0, c2phrase3,0, c3phrase3, 0, c4phrase2, 16, c1phrase4],2);


// The whole piece together:

var main = Pseq([a_section, b_section, a_section],2);

var piece = Pseq([intro,main]);

t = TempoClock.new(150/60);

piece.play(t);


)


// Track 3: SPOOKY THEME ("2-1"):

// FORM:
// A
// B (2x)

// ******** Channel 1 Notes and Durations ***********
(
// this line accomplishes a creepy glissando effect
var c1_slide = Pbind(\instrument, "channel-1", \startNote, 36, \endNote, 24, \dur, Pseq([24]), \amp, 0.05, \speed, 60/120);


// B section:
var note_array = [90,90,84,84,84,85,90,91,90,84]-12; // -12 to drop notes down an octave

var c1phrase1_durs = Pseq([2,2,2,2,1,1,1,1,2,2]);

var c1phrase1_notes = Pseq(note_array);

var c1phrase2_notes = Pseq(note_array-1); // second phrase is half step transposition of first, hence the -1

var c1phrase1 = Pbind(\instrument, "channel-1", \startNote, c1phrase1_notes, \endNote, c1phrase1_notes, \dur, c1phrase1_durs, \staccato, 0.1,\speed, 60/120);

var c1phrase2 = Pbind(\instrument, "channel-1", \startNote, c1phrase2_notes, \endNote, c1phrase2_notes, \dur, c1phrase1_durs, \staccato, 0.1,\speed, 60/120);

var c1_with_fx1 = Pfx(c1phrase1,\delay); // apply delay effect using SynthDef above
var c1_with_fx2 = Pfx(c1phrase2,\delay);

// ******** Channel 2 Notes and Durations ***********

var c_arp = [60,66,65,64];
var b_arp = c_arp - 1; // keep transposing down for each measure
var ab_arp = b_arp - 1;
var g_arp = ab_arp -1;

var c2phrase1_durs = Pseq(Array.fill(28,{1})++2);
var c2phrase1_notes = Pseq(c_arp++c_arp++b_arp++b_arp++ab_arp++ab_arp++g_arp++57);

var c2phrase1 = Pbind(\instrument, "channel-2", \note, c2phrase1_notes, \dur, c2phrase1_durs, \duty, 0.25, \amp, 0.08, \speed, 60/120);


// ******** Channel 3 (bass) Notes and Durations ***********

var bass_durs = Array.fill(7,{4});
var c3_durs = Pseq(bass_durs++2);

var c3phrase1_notes = Pseq([47,47,46,46,45,45,44,44]);

var c3phrase1 = Pbind(\instrument, "channel-3", \note, c3phrase1_notes, \dur, c3_durs,\speed, 60/120);

// all voices assembled:
var a_section = Ptpar([0,c1_slide,0,c2phrase1,0,c3phrase1]);

var b_section = Ptpar([0,c1_with_fx1,0,c2phrase1,0,c3phrase1,16, c1_with_fx2],3);

var piece = Pseq([a_section,b_section]);
t = TempoClock.new(120/60);

piece.play(t);
)

// SOURCES I USED TO FIND INFO ABOUT GAMEBOY/GBA/NES SOUND CHIP / general 8-bit stuff
// https://aselker.github.io/gameboy-sound-chip/
// https://www.coranac.com/tonc/text/sndsqr.htm
// https://ozzed.net/how-to-make-8-bit-music.shtml
// this transcription of pokemon with accurate soundchip info was really helpful to see how things get laid out:
// www.youtube.com/watch?v=2WG9V6C1Aew&t=162s
// musically inspired by the OSTs for Undertale, Pokemon Red/Blue, Sonic Advance, Kirby's Dream Land, Ocarina of Time, Chrono Trigger and many more
