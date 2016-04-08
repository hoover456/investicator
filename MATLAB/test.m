SIMULATION_LENGTH = 365;
% symbols = {'AAPL' 'GOOGL' 'NUGT' 'DUST' 'TSLA' 'AMZN' 'SPXL' 'MIDU' 'TNA' 'SOXL' 'RETL' 'GASL' 'ERX' 'FAS' 'CURE' 'DRN' 'SOXL'};
list = input('File Name: ')
symbols = dataread('file', list, '%s', 'delimiter', '\n');
xlswrite('Suggestions.xls',{'Symbol' 'Suggestion' 'Yesterdays Change' '30 Day Change' '90 Day Change'});
tic;
step = 0;
steps = length(symbols);
h = waitbar(step/steps, 'Beginning');
fid = fopen('newData.txt', 'at');
for r = [1:length(symbols)]
  step = r;
  timePerStep = toc/step;
  waitbar(step/steps, h, strcat(symbols{r},' Elapsed: ', num2str(toc/60,'%.2f'), ' Mins ', ' Remaining: ', num2str((timePerStep * (steps - step))/60, '%.2f'), ' Mins'));
  sugg{1} = symbols{r};
  [suggestion, close] = main(symbols{r});
  if suggestion ~= -2
    fprintf(fid, '%s\n', symbols{r});
    sugg{2} = suggestion;
    sugg{3} = close(end) - close(length(close)-1);
    if length(close) > 30
    sugg{4} = close(end) - close(length(close)-30);
    end
    if length(close) > 90
    sugg{5} = close(end) - close(length(close)-90);
    end
    if sugg{2} > 0.4
      sugg{2} = 'Buy';
    elseif sugg{2} < -0.4
      sugg{2} = 'Sell';
    else
      sugg{2} = 'Wait';
    end
    xlswrite('Suggestions.xls',sugg,strcat('A',int2str(r+1),':E',int2str(r+1)));
  end
end
waitbar(1, h, 'DONE!');
fclose(fid);

% main('AAPL')
% % rets = cell(25,30,40);
% parfor r = [5:25]
%   max = 0;
%   amax = 0;
%   mmax = 0;
%   ret = 0;
%   for a = [10:30]
%     for m = [20:40]
%       ret = main(close, r, a, m);
%       if ret > max
%         max = ret;
%         amax = a;
%         mmax = m;
%       end
%     end
%   end
%   fprintf('r %2.0f a %2.0f m %2.0f ret %.2f%%\n', r, amax, mmax, ret);
% end
% % disp(max(rets));
