---
layout: post
title: "Tutorial: Visualizing Porpoise Clicks (Waveform & Spectrogram)"
author: Jianfeng Tong
date: 2026-01-22 15:00:00
description: A step-by-step guide to plotting acoustic data using Python.
tags: tutorial acoustics python
categories: education
featured: true
---

This tutorial demonstrates how to visualize the echolocation clicks of the **Yangtze Finless Porpoise**. We will use Python to load a `.wav` file, plot its time-domain waveform, and generate a spectrogram to analyze its frequency content.

### 1. The Audio Data

First, let's listen to the echolocation clicks we are going to analyze.

**Note:** Yangtze Finless Porpoise clicks are high-frequency signals (peak energy > 100 kHz), which are well above the human hearing range (typically max 20 kHz).
*   **Original Audio:** You will likely hear *nothing* or very faint clicks because most of the energy is ultrasonic.
*   **Downsampled Audio (Pitch Shifted):** We have resampled the audio to 44.1 kHz (slowing it down) to shift the ultrasonic clicks into the audible range for demonstration purposes.

<div class="row mt-3">
    <div class="col-sm-6 mt-3 mt-md-0">
        <label>Original (Ultrasonic, 2s)</label>
        {% include audio.liquid path="assets/audio/porpoise_clicks_3s.wav" controls=true %}
    </div>
    <div class="col-sm-6 mt-3 mt-md-0">
        <label>Audible Version (Downsampled, 6.7s)</label>
        {% include audio.liquid path="assets/audio/porpoise_clicks_3s_downsampling.wav" controls=true %}
    </div>
</div>

### 2. Python Implementation

We will use `librosa` for audio processing and `matplotlib` for visualization.

#### Requirements
```bash
pip install librosa matplotlib numpy
```

#### The Code

```python
import librosa
import librosa.display
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

# 1. Load the audio file
# sr=None preserves original high sampling rate
audio_path = 'porpoise_clicks_3s.wav'
y, sr = librosa.load(audio_path, sr=None)

# 2. Create the plot with sharex=True to lock the time axis alignment
fig, ax = plt.subplots(nrows=2, ncols=1, figsize=(12, 8), sharex=True)

# --- Top Plot: Waveform (Time Domain) ---
librosa.display.waveshow(y, sr=sr, ax=ax[0], color='blue')
ax[0].set_title('Time Domain Waveform (Aligned)')
ax[0].set_ylabel('Amplitude')
ax[0].grid(True, alpha=0.3)

# --- Bottom Plot: Spectrogram (Frequency Domain) ---
# Use smaller n_fft and hop_length to capture sharp transient clicks
n_fft = 1024
hop_length = 256
D = librosa.amplitude_to_db(np.abs(librosa.stft(y, n_fft=n_fft, hop_length=hop_length)), ref=np.max)

# Draw spectrogram without colorbar
img = librosa.display.specshow(D, 
                               y_axis='linear', 
                               x_axis='time', 
                               sr=sr, 
                               hop_length=hop_length, 
                               ax=ax[1], 
                               cmap='inferno')

# Set frequency display range from 50,000Hz to 192,000Hz
ax[1].set_ylim([50000, 192000])

# Change Y-axis units from Hz to kHz using a Formatter
ax[1].yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos: f'{x/1000:.0f}'))

ax[1].set_title('Spectrogram (50 - 192 kHz)')
ax[1].set_ylabel('Frequency (kHz)')
ax[1].set_xlabel('Time (s)')

# 3. Final layout adjustment
plt.tight_layout()
plt.show()
```

#### Visualization Result

The code above generates the following visualization, showing the precise alignment between the click trains in the time domain and their high-frequency signatures in the spectrogram:

<div class="row mt-3">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/porpoise_3s_plot.png" title="Porpoise Clicks Visualization" class="img-fluid rounded z-depth-1" %}
    </div>
</div>

### 3. Understanding the Results

*   **Waveform (Top)**: Shows the click trains as distinct spikes in amplitude over time. You can clearly see the rhythmic nature of the echolocation behavior.
*   **Spectrogram (Bottom)**: Reveals the spectral energy distribution. Porpoise clicks are broadband but typically have peak energy in very high frequencies (often ultrasonic, >100 kHz), though this recording might be downsampled depending on the hydrophone used.

***

*This tutorial serves as a basic template for acoustic data analysis in our lab.*
