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