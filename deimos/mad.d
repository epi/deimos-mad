/*
 * D header for libmad.
 *
 * libmad - MPEG audio decoder library
 * Copyright (C) 2000-2004 Underbit Technologies, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * If you would like to negotiate alternate licensing terms, you may do
 * so by contacting: Underbit Technologies, Inc. <info@underbit.com>
 */
module deimos.mad;

import core.stdc.config;

extern(C):

alias mad_fixed_t = int;
alias mad_fixed64hi_t = int;
alias mad_fixed64lo_t = uint;
alias mad_sample_t = int;

enum MAD_BUFFER_GUARD = 8;
enum MAD_BUFFER_MDLEN = (511 + 2048 + MAD_BUFFER_GUARD);

enum MAD_F_FRACBITS = 28;
enum MAD_F_ONE      = 0x10000000;

enum mad_units
{
    HOURS = -2,
    MINUTES = -1,
    SECONDS = 0,
    DECISECONDS = 10,
    CENTISECONDS = 100,
    MILLISECONDS = 1000,
    _8000_HZ = 8000,
    _11025_HZ = 11025,
    _12000_HZ = 12000,
    _16000_HZ = 16000,
    _22050_HZ = 22050,
    _24000_HZ = 24000,
    _32000_HZ = 32000,
    _44100_HZ = 44100,
    _48000_HZ = 48000,
    _24_FPS = 24,
    _25_FPS = 25,
    _30_FPS = 30,
    _48_FPS = 48,
    _50_FPS = 50,
    _60_FPS = 60,
    _75_FPS = 75,
    _23_976_FPS = -24,
    _24_975_FPS = -25,
    _29_97_FPS = -30,
    _47_952_FPS = -48,
    _49_95_FPS = -50,
    _59_94_FPS = -60
}

enum mad_error
{
    NONE = 0,
    BUFLEN = 1,
    BUFPTR = 2,
    NOMEM = 49,
    LOSTSYNC = 257,
    BADLAYER = 258,
    BADBITRATE = 259,
    BADSAMPLERATE = 260,
    BADEMPHASIS = 261,
    BADCRC = 513,
    BADBITALLOC = 529,
    BADSCALEFACTOR = 545,
    BADMODE = 546,
    BADFRAMELEN = 561,
    BADBIGVALUES = 562,
    BADBLOCKTYPE = 563,
    BADSCFSI = 564,
    BADDATAPTR = 565,
    BADPART3LEN = 566,
    BADHUFFTABLE = 567,
    BADHUFFDATA = 568,
    BADSTEREO = 569
}

enum mad_option
{
    IGNORECRC = 1,
    HALFSAMPLERATE = 2
}

enum mad_layer
{
    I = 1,
    II = 2,
    III = 3
}

enum mad_mode
{
    SINGLE_CHANNEL = 0,
    DUAL_CHANNEL = 1,
    JOINT_STEREO = 2,
    STEREO = 3
}

enum mad_emphasis
{
    NONE = 0,
    _50_15_US = 1,
    CCITT_J_17 = 3,
    RESERVED = 2
}

enum mad_flag
{
    NPRIVATE_III = 7,
    INCOMPLETE = 8,
    PROTECTION = 16,
    COPYRIGHT = 32,
    ORIGINAL = 64,
    PADDING = 128,
    I_STEREO = 256,
    MS_STEREO = 512,
    FREEFORMAT = 1024,
    LSF_EXT = 4096,
    MC_EXT = 8192,
    MPEG_2_5_EXT = 16384
}

enum mad_private
{
    HEADER = 256,
    III = 31
}

enum _Anonymous_4
{
    MAD_PCM_CHANNEL_SINGLE = 0
}

enum _Anonymous_5
{
    MAD_PCM_CHANNEL_DUAL_1 = 0,
    MAD_PCM_CHANNEL_DUAL_2 = 1
}

enum _Anonymous_6
{
    MAD_PCM_CHANNEL_STEREO_LEFT = 0,
    MAD_PCM_CHANNEL_STEREO_RIGHT = 1
}

enum mad_decoder_mode
{
    SYNC = 0,
    ASYNC = 1
}

enum mad_flow
{
    CONTINUE = 0,
    STOP = 16,
    BREAK = 17,
    IGNORE = 32
}

struct mad_bitptr
{
    const(ubyte)* byte_;
    ushort cache;
    ushort left;
}

struct mad_timer_t
{
    c_long seconds;
    c_ulong fraction;
}

struct mad_stream
{
    const(ubyte)* buffer;
    const(ubyte)* bufend;
    c_ulong skiplen;
    int sync;
    c_ulong freerate;
    const(ubyte)* this_frame;
    const(ubyte)* next_frame;
    mad_bitptr ptr;
    mad_bitptr anc_ptr;
    uint anc_bitlen;
    char[MAD_BUFFER_MDLEN]* main_data;
    uint md_len;
    int options;
    mad_error error;
}

struct mad_header
{
    mad_layer layer;
    mad_mode mode;
    int mode_extension;
    mad_emphasis emphasis;
    c_ulong bitrate;
    uint samplerate;
    ushort crc_check;
    ushort crc_target;
    int flags;
    int private_bits;
    mad_timer_t duration;
}

struct mad_frame
{
    mad_header header;
    int options;
    mad_fixed_t[32][36][2] sbsample;
    mad_fixed_t[18][32][2]* overlap;
}

struct mad_pcm
{
    uint samplerate;
    ushort channels;
    ushort length;
    mad_fixed_t[1152][2] samples;
}

struct mad_synth
{
    mad_fixed_t[8][16][2][2][2] filter;
    uint phase;
    mad_pcm pcm;
}

private struct _mad_decoder_sync
{
    c_long pid;
    int in_;
    int out_;
}

struct mad_decoder
{
    mad_decoder_mode mode;
    int options;
    _mad_decoder_sync* sync;
    void* cb_data;
    mad_flow function (void*, mad_stream*) input_func;
    mad_flow function (void*, const(mad_header)*) header_func;
    mad_flow function (void*, const(mad_stream)*, mad_frame*) filter_func;
    mad_flow function (void*, const(mad_header)*, mad_pcm*) output_func;
    mad_flow function (void*, mad_stream*, mad_frame*) error_func;
    mad_flow function (void*, void*, uint*) message_func;
}

mad_fixed_t mad_f_abs (mad_fixed_t);
mad_fixed_t mad_f_div (mad_fixed_t, mad_fixed_t);
void mad_bit_init (mad_bitptr*, const(ubyte)*);
uint mad_bit_length (const(mad_bitptr)*, const(mad_bitptr)*);
const(ubyte)* mad_bit_nextbyte (const(mad_bitptr)*);
void mad_bit_skip (mad_bitptr*, uint);
c_ulong mad_bit_read (mad_bitptr*, uint);
void mad_bit_write (mad_bitptr*, uint, c_ulong);
ushort mad_bit_crc (mad_bitptr, uint, ushort);
int mad_timer_compare (mad_timer_t, mad_timer_t);
void mad_timer_negate (mad_timer_t*);
mad_timer_t mad_timer_abs (mad_timer_t);
void mad_timer_set (mad_timer_t*, c_ulong, c_ulong, c_ulong);
void mad_timer_add (mad_timer_t*, mad_timer_t);
void mad_timer_multiply (mad_timer_t*, c_long);
c_long mad_timer_count (mad_timer_t, mad_units);
c_ulong mad_timer_fraction (mad_timer_t, c_ulong);
void mad_timer_string (mad_timer_t, char*, const(char)*, mad_units, mad_units, c_ulong);
void mad_stream_init (mad_stream*);
void mad_stream_finish (mad_stream*);
void mad_stream_buffer (mad_stream*, const(ubyte)*, c_ulong);
void mad_stream_skip (mad_stream*, c_ulong);
int mad_stream_sync (mad_stream*);
const(char)* mad_stream_errorstr (const(mad_stream)*);
void mad_header_init (mad_header*);
int mad_header_decode (mad_header*, mad_stream*);
void mad_frame_init (mad_frame*);
void mad_frame_finish (mad_frame*);
int mad_frame_decode (mad_frame*, mad_stream*);
void mad_frame_mute (mad_frame*);
void mad_synth_init (mad_synth*);
void mad_synth_mute (mad_synth*);
void mad_synth_frame (mad_synth*, const(mad_frame)*);
void mad_decoder_init (mad_decoder*, void*, mad_flow function (void*, mad_stream*), mad_flow function (void*, const(mad_header)*), mad_flow function (void*, const(mad_stream)*, mad_frame*), mad_flow function (void*, const(mad_header)*, mad_pcm*), mad_flow function (void*, mad_stream*, mad_frame*), mad_flow function (void*, void*, uint*));
int mad_decoder_finish (mad_decoder*);
int mad_decoder_run (mad_decoder*, mad_decoder_mode);
int mad_decoder_message (mad_decoder*, void*, uint*);

