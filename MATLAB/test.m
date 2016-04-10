SIMULATION_LENGTH = 365;
list = input('File Name: ')
symbols = dataread('file', list, '%s', 'delimiter', '\n');
fid = fopen('suggestions.csv', 'wt');
header = {'Symbol' 'Suggestion' 'Yesterdays Change' '30 Day Change' '90 Day Change' 'RSI_accuracy' 'aroon_accuracy' 'macd_accuracy' 'obv_accuracy' 'stoch_accuracy' 'mean_accuracy'};
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s', header{:});
fclose(fid);
dlmwrite('suggestions.csv',['_'], '-append');
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
  [suggestion, close, accuracies] = main(symbols{r});
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
    % sugg{end:length(accuracies) + end} = accuracies{:}
    sugg = [sugg accuracies(2:end)];
    fid = fopen('suggestions.csv', 'at');
    fprintf(fid, '%s,%s,', sugg{1:2});
    fclose(fid);
    dlmwrite('suggestions.csv', sugg(3:end), '-append');
    % xlswrite('Suggestions.xls',sugg,strcat('A',int2str(r+1),':K',int2str(r+1)));
    clear sugg;
  end
end
waitbar(1, h, 'DONE!');
clear
