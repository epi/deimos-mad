import deimos.mad;

struct Buffer
{
    const(ubyte)* start;
    ulong length;
    ulong previous = ulong.max;
    bool started;
}

extern(C)
mad_flow input(void* data, mad_stream* stream)
{
    import std.algorithm : min;
    import std.stdio : stderr, writefln;

    Buffer* buffer = cast(Buffer*) data;

    ulong offs = buffer.started
        ? stream.this_frame - buffer.start
        : 0;
    auto len = min(buffer.length - offs, 16384);
    if (!len)
        return mad_flow.STOP;
    if (buffer.previous == offs)
        return mad_flow.STOP;
    buffer.started = true;

    mad_stream_buffer(stream, buffer.start + offs, len);

    buffer.previous = offs;
    return mad_flow.CONTINUE;
}

int scale(mad_fixed_t sample)
{
    /* round */
    sample += (1L << (MAD_F_FRACBITS - 16));

    /* clip */
    if (sample >= MAD_F_ONE)
        sample = MAD_F_ONE - 1;
    else if (sample < -MAD_F_ONE)
        sample = -MAD_F_ONE;

    /* quantize */
    return sample >> (MAD_F_FRACBITS + 1 - 16);
}

extern(C)
mad_flow output(void* data, const(mad_header)* header, mad_pcm* pcm)
{
    uint nchannels, nsamples;
    const(mad_fixed_t)* left_ch;
    const(mad_fixed_t)* right_ch;

    /* pcm->samplerate contains the sampling frequency */

    nchannels = pcm.channels;
    nsamples  = pcm.length;
    left_ch   = pcm.samples[0].ptr;
    right_ch  = pcm.samples[1].ptr;

    while (nsamples--) {
        import core.stdc.stdio : putchar;
        int sample;

        /* output sample(s) in 16-bit signed little-endian PCM */
        sample = scale(*left_ch++);
        putchar((sample >> 0) & 0xff);
        putchar((sample >> 8) & 0xff);

        if (nchannels == 2) {
            sample = scale(*right_ch++);
            putchar((sample >> 0) & 0xff);
            putchar((sample >> 8) & 0xff);
        }
    }

    return mad_flow.CONTINUE;
}

extern(C)
mad_flow error(void* data, mad_stream* stream, mad_frame* frame)
{
    import std.stdio : stderr;
    import std.string : fromStringz;

    auto buffer = cast(Buffer*) data;

    stderr.writefln("decoding error 0x%04x (%s) at byte offset %08x",
        stream.error, mad_stream_errorstr(stream).fromStringz,
        stream.this_frame - buffer.start);

    /* return mad_flow.BREAK here to stop decoding (and propagate an error) */
    return mad_flow.CONTINUE;
}

int decode(void* start, ulong length)
{
    Buffer buffer;
    mad_decoder decoder;
    int result;

    /* initialize our private message structure */
    buffer.start  = cast(const(ubyte)*) start;
    buffer.length = length;

    /* configure input, output, and error functions */
    mad_decoder_init(&decoder, &buffer,
        &input, null /* header */, null /* filter */, &output,
        &error, null /* message */);

    /* start decoding */
    result = mad_decoder_run(&decoder, mad_decoder_mode.SYNC);

    /* release the decoder */
    mad_decoder_finish(&decoder);

    return result;
}

int main(string[] args)
{
    import core.sys.posix.sys.stat;
    import core.sys.posix.sys.mman;
    import core.sys.posix.unistd;

    stat_t st;
    void *fdm;

    if (args.length != 1)
        return 1;

    if (fstat(STDIN_FILENO, &st) == -1 || st.st_size == 0)
        return 2;

    fdm = mmap(null, st.st_size, PROT_READ, MAP_SHARED, STDIN_FILENO, 0);
    if (fdm == MAP_FAILED)
        return 3;

    decode(fdm, st.st_size);

    if (munmap(fdm, st.st_size) == -1)
        return 4;

    return 0;
}

