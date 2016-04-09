SIMULATION_LENGTH = 365;
list = input('File Name: ')
symbols = dataread('file', list, '%s', 'delimiter', '\n');
xlswrite('Suggestions.xls',{'Symbol' 'Suggestion' 'Yesterdays Change' '30 Day Change' '90 Day Change'});
tic;
step = 0;
steps = length(symbols);
h = waitbar(step/steps, 'Beginning');
fid2 = fopen('accuracies.csv', 'wt');
fprintf(fid2, '%s', 'symbol, RSI_accuracy, aroon_accuracy, macd_accuracy, obv_accuracy, stoch_accuracy,');
fclose(fid2);
dlmwrite('accuracies.csv',['_'], '-append');

for r = [1:length(symbols )]
  step = r;
  timePerStep = toc/step;
  waitbar(step/steps, h, strcat(symbols{r},' Elapsed: ', num2str(toc/60,'%.2f'), ' Mins ', ' Remaining: ', num2str((timePerStep * (steps - step))/60, '%.2f'), ' Mins'));
  sugg{1} = symbols{r};
  [suggestion, close] = main(symbols{r});
  if suggestion ~= -2
    sugg{2} = suggestion;
    sugg{3} = close(end) - close(length(close)-1);
    if length(close) > 30
    sugg{4} = close(end) - close(length(close)-30);
    end
    if length(close) > 90
    sugg{5} = close(end) - close(length(close)-90);
    end
    if sugg{2} > 0.5
      sugg{2} = 'Buy';
    elseif sugg{2} < -0.5
      sugg{2} = 'Sell';
    else
      sugg{2} = 'Wait';
    end
    xlswrite('Suggestions.xls',sugg,strcat('A',int2str(r+1),':E',int2str(r+1)));
  end
end
waitbar(1, h, 'DONE!');
clear
