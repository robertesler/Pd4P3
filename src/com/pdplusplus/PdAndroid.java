package com.pdplusplus;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;

import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioTrack;
import android.media.AudioRecord;
import android.media.MediaRecorder;


public class PdAndroid extends PdMaster implements Runnable {

    boolean play = true;
    double [] output;
    double [] input;
    int outputChannels = 2;
    int inputChannels = 1;

    protected short[] shortBuffer;
    protected int frameRate = 48000;
    protected int samplesPerFrame;
    protected int minBufferSize;
    protected int bufferSize;
    protected int deviceID;
    protected int blockSize = 64;

    boolean inputPermissions = false;

    protected int minInputBufferSize;
    protected int inputBufferSize;

    PdAlgorithm pd;

    AudioTrack audioTrack;
    AudioRecord audioRecord;

    /*You need to pass PdAlgorithm to this method*/
    public PdAndroid(PdAlgorithm pda){
        pd = pda;
    }

    public void setInputChannels(int i) {
        inputChannels = i;
    }

    public void setInputPermissions(boolean b) {
        inputPermissions = b;
    }

    public void setBlockSize(int bs) {
        pd.setBlockSize(bs);
        blockSize = bs;
    }

    private void writeData() throws InterruptedException
    {
        samplesPerFrame = blockSize;
        input = new double[samplesPerFrame];
        output = new double[samplesPerFrame * outputChannels];
        int r = 0;

         while(play)
        {
            int outputIndex = 0;
            int inputIndex = 0;

            try {
                if(inputPermissions)
                {
                    r = read(input, 0, input.length);
                }

            } catch (Exception e)
            {
                Log.d("PD ANDROID: ", e.toString());
                Log.d("PD ANDROID: read = ", String.valueOf(r));
            }

            for (int i = 0; i < samplesPerFrame; i++) {
                    double in1 = 0;
                    if(inputPermissions)
                    {
                        in1 = input[inputIndex++];
                    }


                    pd.runAlgorithm(in1, 0);

                    output[outputIndex++] = PdAlgorithm.outputL;
                    output[outputIndex++] = PdAlgorithm.outputR;
            }

            write(output, 0, output.length);
        }
    }

    private void write(double[] buffer, int start, int count) {
        if ((shortBuffer == null) || (shortBuffer.length < count)) {
            shortBuffer = new short[count];
        }

        for (int i = 0; i < count; i++) {
            int sample = (int) (32767.0 * buffer[i + start]);
            if (sample > Short.MAX_VALUE) {
                sample = Short.MAX_VALUE;
            } else if (sample < Short.MIN_VALUE) {
                sample = Short.MIN_VALUE;
            }
            shortBuffer[i] = (short) sample;
        }

        audioTrack.write(shortBuffer, 0, count);
    }

    private int read(double[] buffer, int start, int count) {
        if (audioRecord == null) {
            return 0;
        }

        if ((shortBuffer == null) || (shortBuffer.length < count)) {
            shortBuffer = new short[count];
        }

        int read = audioRecord.read(shortBuffer, 0, count, AudioRecord.READ_NON_BLOCKING);

        if (read < 0) {
            switch (read) {
                case AudioRecord.ERROR_INVALID_OPERATION:
                    throw new RuntimeException("AudioRecord ERROR_INVALID_OPERATION: Device not properly initialized");
                case AudioRecord.ERROR_BAD_VALUE:
                    throw new RuntimeException("AudioRecord ERROR_BAD_VALUE: Paramters don't resolve to valid data and indices");
                case AudioRecord.ERROR_DEAD_OBJECT:
                    throw new RuntimeException("AudioRecord ERROR_DEAD_OBJECT: Object must be recreated");
                case AudioRecord.ERROR:
                    throw new RuntimeException("AudioRecord ERROR: Unknown error");
            }
        }

        for (int i = 0; i < read; i++) {
            buffer[i + start] = shortBuffer[i] / 32767.0;
        }

        return read;
    }

    @Override
    public void run() {

        try
        {
            writeData();
        }
        catch (Exception e)
        {
            Log.d("PD OBOE: %s", e.toString());
        }
    }


    public void start() {
        /*Our output stream*/
        minBufferSize = AudioTrack.getMinBufferSize(frameRate, AudioFormat.CHANNEL_OUT_STEREO,
                AudioFormat.ENCODING_PCM_16BIT);
        bufferSize = (3 * (minBufferSize / 2)) & ~3;
        audioTrack = new AudioTrack.Builder()
                .setAudioAttributes(new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build())
                .setAudioFormat(new AudioFormat.Builder()
                        .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(frameRate)
                        .build())
                .setBufferSizeInBytes(bufferSize/2)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
                .build();
       // audioTrack.setBufferSizeInFrames(blockSize*4);
        audioTrack.play();
        pd.setSampleRate(frameRate);

        /*Our input stream*/
        if(inputPermissions)
        {
            minInputBufferSize = AudioRecord.getMinBufferSize(frameRate, AudioFormat.CHANNEL_OUT_STEREO,
                    AudioFormat.ENCODING_PCM_16BIT);

            inputBufferSize = (3 * (minInputBufferSize / 2)) & ~3;

            try {
                audioRecord = new AudioRecord.Builder()
                        .setAudioSource(this.deviceID)
                        .setAudioFormat(new AudioFormat.Builder()
                                .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(frameRate)
                                .build())
                        .setBufferSizeInBytes(inputBufferSize)
                        .build();
                audioRecord.startRecording();

            } catch (SecurityException e) {
                // fail silently: if the user actually wants to capture audio,
                // instantiating AudioIn will produce an informative exception
                Log.e("PD ANDROID: ", String.valueOf(e));
            }
        }

    }

    public void stop() {
        if (audioTrack != null) {
            audioTrack.stop();
            audioTrack.release();
        }

        if (audioRecord != null) {
            audioRecord.stop();
            audioRecord.release();
        }
    }

    public void pause() {
        play = false;
    }

    public void play() {
        play = true;
    }

    public boolean isPlaying() {
        return play;
    }

    public void free() {
        pd.free();

    }


}
