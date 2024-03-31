clc; clear;

% 오디오 데이터 로딩
[audioData, sampleFreq] = audioread('Received_Signal.wav');

% STFT 설정
fftSize = 2048;  % FFT 점 수
windowFunc = hamming(fftSize);  % 윈도우 함수
overlapLength = length(windowFunc) / 2;  % 오버랩 크기
hopLength = fftSize - overlapLength;  % 홉 크기

% 신호 패키지 로드
pkg load signal

% 밴드패스 필터 생성
filterOrder = 100; % 필터 차수
lowCutOffFreq = 2600; % 하위 차단 주파수
highCutOffFreq = 3400; % 상위 차단 주파수
bandpassFilter = fir1(filterOrder, [lowCutOffFreq highCutOffFreq]/(sampleFreq/2), 'bandpass');

% STFT 계산 (간섭 전)
stftArray = [];  % STFT 결과 저장 배열 초기화
for i = 1:hopLength:(length(audioData)-fftSize)
    windowedFrame = audioData(i:i+fftSize-1) .* windowFunc;  % 윈도우 적용
    stftArray(:, end+1) = fft(windowedFrame, fftSize);  % FFT 수행
end

% 주파수 및 시간 축 계산
FreqAxis = linspace(0, sampleFreq, fftSize);
TimeAxis = (0:(size(stftArray, 2)-1)) * (hopLength / sampleFreq);

% 스펙트로그램 플로팅 (간섭 전)
figure;
imagesc(TimeAxis, FreqAxis, 20*log10(abs(stftArray)));
axis xy;
colormap('jet');
colorbar;
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram of the Original Audio Signal');

% 밴드패스 필터 적용
filteredAudioData = filter(bandpassFilter, 1, audioData);

% STFT 계산 (간섭 후)
stftArray = [];  % STFT 결과 저장 배열 초기화
for i = 1:hopLength:(length(filteredAudioData)-fftSize)
    windowedFrame = filteredAudioData(i:i+fftSize-1) .* windowFunc;  % 윈도우 적용
    stftArray(:, end+1) = fft(windowedFrame, fftSize);  % FFT 수행
end

% 주파수 범위 2600Hz에서 3400Hz로 필터링
desiredFreqRange = (FreqAxis >= 2600) & (FreqAxis <= 3400);
filteredStftArray = stftArray(desiredFreqRange, :);
filteredFreqAxis = FreqAxis(desiredFreqRange);

% 스펙트로그램 플로팅 (간섭 후)
figure;
imagesc(TimeAxis, FreqAxis, 20*log10(abs(filteredStftArray)));
axis xy;
colormap('jet');
colorbar;
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram of the Audio Signal with Bandpass Filter');
% 필터링 전 스펙트로그램 플로팅
figure;
imagesc(TimeAxis, FreqAxis, 20*log10(abs(stftArray)));
axis xy;
colormap('jet');
colorbar;
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Original Spectrogram');

% 필터링 후 스펙트로그램 플로팅
figure;
imagesc(TimeAxis, filteredFreqAxis, 20*log10(abs(filteredStftArray)));
axis xy;
colormap('jet');
colorbar;
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram after Bandpass Filtering (2600-3400Hz)');

% 필터링 전후의 주파수 대역 비교
figure;
subplot(2,1,1);
plot(TimeAxis, 20*log10(abs(stftArray(2600:3400, :))));
title('Original Frequency Range (2600-3400Hz)');
xlabel('Time [s]');
ylabel('Amplitude [dB]');

subplot(2,1,2);
plot(TimeAxis, 20*log10(abs(filteredStftArray)));
title('Filtered Frequency Range (2600-3400Hz)');
xlabel('Time [s]');
ylabel('Amplitude [dB]');

