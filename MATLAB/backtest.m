function backtest(listName)


  symbols = dataread('file', listName, '%s', 'delimiter', '\n'); % Read in list of symbols

  % Get 2 years data for each symbol
  steps = length(symbols);
  h = waitbar(0/steps, 'GETTING DATA');
  market = zeros(length(symbols),1);
  for i = 1:steps
    waitbar(i/steps, h, strcat(num2str(i), '/', num2str(steps)));
    if exist(strcat('Data/',symbols{i}, '.csv'), 'file') == 2
      data = dlmread(strcat('Data/',symbols{i}, '.csv'));
      close = data(1,:);
      volume = data(2,:);
      adjClose = data(3,:);
    else
      data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbols{i}));
      if height(data) >= 730
        SIMULATION_LENGTH = 730;
      else
        continue;
      end
      data = data(1:SIMULATION_LENGTH,:);
      close = fliplr(table2array(data(:,5))');
      volume = fliplr(table2array(data(:,6))');
      adjClose = fliplr(table2array(data(:,7))');
      fid = fopen(strcat('Data/',symbols{i},'.csv'),'wt');
      fclose(fid);
      dlmwrite(strcat('Data/',symbols{i},'.csv'), [close; volume; adjClose]);
    end
    market(i) = stock;
    market(i).symbol = symbols{i};
    market(i).closes = close;
    market(i).adjCloses = adjClose;
    market(i).volumes = volume;
  end
  i = 1;
while i < length(market)
  if ISEMPTY(market(i).symbol) == 0
    market = [market(1:i-1) market(i+1:end)];
    i = i - 1;
  end
  i = i + 1;
end
% PORTFOLIO SETUP
funds = 100000;
net = funds;
% portfolio = [stock];

% n = 365;
%r = length(market);
steps = 365;
% h = waitbar(n-365/steps, 'SIMULATING');
for n = 365:730
  waitbar(n-364/steps,h, n-364);
  for i = 1:length(market)-1
    [market(i).suggestion, market(i).inaccuracy] = main(market(i).symbol, market(i).adjCloses(n-364:n), market(i).volumes(n-364:n), 365);
  end

  for j = 1:length(market)
      if (market(j).sharesOwned > 0 && market(j).suggestion == -1) || market(i).purchasePrice > 0 && (market(i).closes(n) / market(i).purchasePrice) >= 1.03
        %|| (market(j).sharesOwned > 0 && abs(market(j).closes(n) - market(j).purchasePrice) / market(j).purchasePrice >=0.1)
        fprintf('SELLING %.0f SHARES OF %s FOR $%.2f PER SHARE\n', market(j).sharesOwned, market(j).symbol, market(j).closes(n))
        funds = funds + market(j).sell(n);
        market(j).sharesOwned = 0;
        % disp(market(j).sharesOwned)
        net = funds;
        for p = 1:length(market)
          net = net + market(p).sharesOwned * market(p).closes(n);
        end
        % market(j).sharesOwned
      end
  end
  [~, indexes] = sort([market.inaccuracy]);
  
  %{
  for e = 1:length(market)
    temp(e) = market(indexes(e));
  end
    %}
  temp = market(indexes);
  market = temp;

  for i = 1:length(market)
    if funds > net / 5
      if market(i).suggestion == 1 && market(i).sharesOwned == 0
        market(i).purchasePrice = market(i).closes(n);
        market(i).sharesOwned = market(i).sharesOwned + floor((funds / 5) / market(i).purchasePrice);
        fprintf('BUYING %.0f SHARES OF %s AT $%5.2f PER SHARE\n', (floor((funds / 5) / market(i).purchasePrice)), market(i).symbol, market(i).purchasePrice)
        funds = funds - (floor((funds / 5) / market(i).purchasePrice)) * market(i).purchasePrice;
        net = funds;
        for p = 1:length(market)
          % fprintf('%d %.0f\n', p, market(i).sharesOwned)
          net = net + (market(p).sharesOwned * market(p).closes(n));
        end
      end
    end
  end

  % BUY UNTIL LESS THAN 1/5 of portfolio is cash
  % disp([market.sharesOwned])
  net = funds;
  for p = 1:length(market)
    % fprintf('%d %.0f\n', p, market(i).sharesOwned)
    net = net + (market(p).sharesOwned * market(p).closes(n));
  end
  fprintf('%.0f $%5.2f $%5.2f\n', n, funds, net);
end
