
%MAIN Summary of this function goes here
%   Detailed explanation goes here
%symbol = input('test: ', 's');

%INITIAL SETUP
clear;
format compact;

% CONSTANTS
symbol = 'NUGT';
SIMULATION_LENGTH = 200;

% GET DATA FROM YAHOO FINANCE
data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbol));
data = data(1:SIMULATION_LENGTH,:);
dates = datenum(table2array(data(:,1)));
open = table2array(data(:,2))';
high = table2array(data(:,3))';
low = table2array(data(:,4))';
close = table2array(data(:,5))';
volume = table2array(data(:,6))';
adjClose = table2array(data(:,7))';

[macd, sig, macd_predictions] = MACD(close);
[aroon, aroon_predictions] = aroon(close);
[RSI, RSI_predictions] = RSI(close);
