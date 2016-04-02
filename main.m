
%MAIN Summary of this function goes here
%   Detailed explanation goes here
%symbol = input('test: ', 's');
symbol = 'NUGT';
data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbol));
test = fints(table2array(data(2:end,1)), table2array(data(2:end,2:end),'VariableNames',{'Date' 'Open' 'High' 'Low' 'Close' 'Volume' 'AdjClose'}));
test = chfield(test, {'series1' 'series2' 'series3' 'series4' 'series5' 'series6'}, {'Open' 'High' 'Low' 'Close' 'Volume' 'AdjClose'});
