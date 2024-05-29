%Yue Zhang
%ssyyz50@nottingham.ed.ucn

% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]
duration = 300;
temperatures = load('cabin_temperatures.txt');
time = 0:1:300;
plot(time, temperatures);
xlabel('Time(seconds)');
ylabel('Temperature(°c)');
title('Temperature vs Time');
dateRecorded='2024-05-28';
location ='Cabin';
data = temperatures;
fprintf('Date: %s\nLocation: %s\n\n', dateRecorded, location);
for i= 0:duration-1
    fprintf('Minute %d:\t %.2f°c\n',i, data(i+1));
        if mod(i+1,60)==0
    fprintf('\n');
        end
end
fileID = fopen('cabin_temperature.txt', 'w');
fprintf(fileID, 'Date: %s\nLocation: %s\n\n', dateRecorded, location);
for i = 0:duration-1
    fprintf(fileID, 'Minute %d:\t %.2f°C\n', i, data(i+1));
    if mod(i+1, 60) == 0
        fprintf(fileID, '\n');
    end
end
fclose(fileID);
fileID = fopen('cabin_temperature.txt', 'r');
fileContent = fread(fileID, '*char')';
fclose(fileID);
disp(fileContent);

% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]
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

% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]
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

% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]
%The project involved using Arduino to develop a temperature monitoring system that can control leds and predict future temperature changes. 
%Throughout the project, we encountered a number of challenges, strengths were identified, limitations were identified, and future improvements were suggested.
%Challenge:
%One of the main challenges is to ensure the stability and accuracy of temperature readings
%The power supply of the Arduino introduces noise that affects the output of the sensor. To mitigate this, the resistor is
%Used to stabilize readings. Another challenge is to achieve real-time LED control of the temperature range and rate of change. 
%Ensuring that leds flash at the correct intervals while maintaining accurate temperature readings requires precise timing and careful code structure.
%Advantages:
%The project successfully demonstrated the ability to monitor and visualize temperature changes in real time.
%Instant feedback via LED indicator. Drawing and integrating with MATLAB to predict the future temperature improved the analytical capability of the project. 
%In addition, the project demonstrates the versatility of Arduino in handling data acquisition and actuator control.
%Limitations:
%Despite the many advantages of this project, there are some limitations. The accuracy of a temperature sensor is subject to its specifications, which can introduce errors in the reading. 
%The prediction model assumes a constant rate of percentage change over the next five minutes, which may not always be accurate due to fluctuations in the environment. In addition, the system currently operates continuously without defined end conditions, which may not be suitable for long-term monitoring applications.
%Future improvements:
%Some improvements can be made to improve the accuracy of the project. Implementing a more sophisticated noise reduction technique, such as an average filter, can further stabilize sensor readings. 
%The accuracy of temperature forecasts can be improved by combining historical data and using regression to enhance predictive model techniques. 
%Adding parameters to adjust the user interface, such as temperature thresholds and monitoring duration, will make the system more reliable to adapt to different scenarios. 
%Finally, integrated wireless communication modules, such as Wi-Fi or Bluetooth, will allow remote monitoring and control, expanding the applicability of the system.
%In summary, the project provides a method for real-time temperature monitoring and control through the use of Arduino and MATLAB. Despite the challenges and limitations, the project demonstrates a solid foundation for further development and improvement. 
%By addressing identified limitations and implementing proposed enhancements, the system can become a more reliable and versatile solution for temperature monitoring applications.
