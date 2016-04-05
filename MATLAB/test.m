SIMULATION_LENGTH = 365;
symbols = {'AAPL' 'GOOGL' 'NUGT' 'DUST' 'TSLA' 'AMZN' 'SPXL' 'MIDU' 'TNA' 'SOXL' 'RETL' 'GASL' 'MATL' 'ERX' 'FAS' 'CURE' 'DRN' 'SOXL'}

for r = [1:length(symbols)]
  fprintf('%s: %5.2f%%\n', symbols{r}, main(symbols{r}))
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
