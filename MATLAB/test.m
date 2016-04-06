SIMULATION_LENGTH = 365;
% symbols = {'AAPL' 'GOOGL' 'NUGT' 'DUST' 'TSLA' 'AMZN' 'SPXL' 'MIDU' 'TNA' 'SOXL' 'RETL' 'GASL' 'ERX' 'FAS' 'CURE' 'DRN' 'SOXL'};
list = input('File Name: ')
symbols = dataread('file', list, '%s', 'delimiter', '\n');
xlswrite('Suggestions.xls',{'Symbol' 'Suggestion'});

step = 0;
steps = length(symbols);
h = waitbar(step/steps, 'Beginning');
for r = [1:length(symbols)]
  step = r;
  waitbar(step/steps, h, strcat('Processing:  ',symbols{r}));
  sugg{1} = symbols{r};
  sugg{2} = main(symbols{r});
  if sugg{2} > 0.4
    sugg{2} = 'Buy';
  elseif sugg{2} < -0.4
    sugg{2} = 'Sell';
  else
    sugg{2} = 'Wait';
  end
  xlswrite('Suggestions.xls',sugg,strcat('A',int2str(r+1),':B',int2str(r+1)));
end


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
