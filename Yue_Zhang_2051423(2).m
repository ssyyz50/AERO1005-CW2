function temp_monitor(a)
    %TEMP_MONITOR Monitors temperature and controls LEDs accordingly
    %   This function reads temperature data from an Arduino-connected
    %   sensor, displays it on a live graph, and controls LEDs based on
    %   the temperature range.
    
    % Define pin numbers
    greenLED = 'D2';
    yellowLED = 'D3';
    redLED = 'D4';
    sensorPin = 'A0';
    
    % Setup LEDs as output
    configurePin(a, greenLED, 'DigitalOutput');
    configurePin(a, yellowLED, 'DigitalOutput');
    configurePin(a, redLED, 'DigitalOutput');
    
    % Initialize temperature array
    temperatures = [];
    timeArray = [];
    startTime = datetime('now');
    
    % Live plot setup
    figure;
    h = plot(timeArray, temperatures, '-o');
    xlabel('Time (s)');
    ylabel('Temperature (°C)');
    title('Real-time Temperature Monitoring');
    xlim([0, 600]);
    ylim([0, 50]);
    
    % Monitoring loop
    while true
        % Read voltage from sensor
        voltage = readVoltage(a, sensorPin);
        % Convert voltage to temperature
        temperature = (voltage - 0.5) / 0.01;
        
        % Append temperature and time data
        currentTime = datetime('now');
        elapsedTime = seconds(currentTime - startTime);
        temperatures(end + 1) = temperature; %#ok<AGROW>
        timeArray(end + 1) = elapsedTime; %#ok<AGROW>
        
        % Update plot
        set(h, 'XData', timeArray, 'YData', temperatures);
        drawnow;
        
        % Control LEDs based on temperature
        if temperature >= 18 && temperature <= 24
            writeDigitalPin(a, greenLED, 1);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
        elseif temperature < 18
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, redLED, 0);
            writeDigitalPin(a, yellowLED, 1);
            pause(0.5);
            writeDigitalPin(a, yellowLED, 0);
            pause(0.5);
        elseif temperature > 24
            writeDigitalPin(a, greenLED, 0);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 1);
            pause(0.25);
            writeDigitalPin(a, redLED, 0);
            pause(0.25);
        end
        
        % Pause for 1 second
        pause(1);
    end
end
%TEMP_MONITOR Monitors temperature and controls LEDs accordingly
%   This function reads temperature data from an Arduino-connected
%   sensor, displays it on a live graph, and controls LEDs based on
%   the temperature range.
%   - Green LED: Constant light if temperature is between 18-24°C.
%   - Yellow LED: Blinks at 0.5s intervals if temperature is below 18°C.
%   - Red LED: Blinks at 0.25s intervals if temperature is above 24°C.
%   The function runs indefinitely, updating the graph and controlling
%   the LEDs in real-time.
