filename = 'cabin_temperatures.txt';
fid = fopen(filename, 'w');
fprintf(fid, '%.5f\n', data);
fclose(fid);
x = 1:300; 
y = load('cabin_temperatures.txt'); 
if length(y) ~= 300
    error('the length of data is not 300');
end

p = polyfit(x, y, 1);

slope = p(1)*60;

y_fit = polyval(p, x);

figure;
plot(x, y, 'bo', 'DisplayName', 'Original Data');
hold on;
plot(x, y_fit, '-r', 'LineWidth', 2, 'DisplayName', 'Fitted Line'); 
xlabel('Index');
ylabel('Value');
title('Linear Fit of Data');
legend;
grid on; 
hold off;

fprintf('The slope of the fitted line is: %f\n', slope);

function temp_prediction(a)
    %TEMP_PREDICTION Monitors temperature changes and predicts future temperature
    %   This function reads temperature data from an Arduino-connected
    %   sensor, calculates the rate of change of temperature, and predicts
    %   the temperature 5 minutes into the future. It controls LEDs based
    %   on the rate of temperature change.
    
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
    title('Real-time Temperature Monitoring and Prediction');
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
        
        % Calculate temperature change rate
        if length(temperatures) > 1
            deltaTemp = temperatures(end) - temperatures(end-1);
            deltaTime = timeArray(end) - timeArray(end-1);
            tempRate = deltaTemp / deltaTime; % °C/s
            
            % Convert rate to °C/min
            tempRateMin = tempRate * 60;
            
            % Predict temperature in 5 minutes
            predictedTemp = temperature + (tempRate * 300); % 300 seconds = 5 minutes
            
            % Print current temperature, rate, and predicted temperature
            fprintf('Current Temperature: %.2f°C\n', temperature);
            fprintf('Temperature Change Rate: %.2f°C/s\n', tempRate);
            fprintf('Predicted Temperature in 5 minutes: %.2f°C\n', predictedTemp);
            
            % Control LEDs based on temperature change rate
            if tempRateMin >= -4 && tempRateMin <= 4
                writeDigitalPin(a, greenLED, 1);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 0);
            elseif tempRateMin > 4
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 0);
                writeDigitalPin(a, redLED, 1);
            elseif tempRateMin < -4
                writeDigitalPin(a, greenLED, 0);
                writeDigitalPin(a, yellowLED, 1);
                writeDigitalPin(a, redLED, 0);
            end
        end
        
        % Pause for 1 second
        pause(1);
    end
end
%TEMP_PREDICTION Monitors temperature changes and predicts future temperature
%   This function reads temperature data from an Arduino-connected
%   sensor, calculates the rate of change of temperature, and predicts
%   the temperature 5 minutes into the future. It controls LEDs based
%   on the rate of temperature change.
%   - Green LED: Constant light if temperature change rate is between -4°C/min and 4°C/min.
%   - Yellow LED: Constant light if temperature change rate is below -4°C/min.
%   - Red LED: Constant light if temperature change rate is above 4°C/min.
%   The function runs indefinitely, updating the graph, predicting future temperature,
%   and controlling the LEDs in real-time.
