function backtest(listName)


  symbols = dataread('file', listName, '%s', 'delimiter', '\n'); % Read in list of symbols

  % Get 2 years data for each symbol
  steps = length(symbols);
  h = waitbar(0/steps, 'GETTING DATA');
  % market = zeros(length(symbols),1);
  for i = 1:steps
    waitbar(i/steps, h, strcat(num2str(i), '/', num2str(steps)));
    market(i) = stock;
    if exist(strcat('Data/',symbols{i}, '.csv'), 'file') == 2
      data = dlmread(strcat('Data/',symbols{i}, '.csv'));
      close = data(1,:);
      volume = data(2,:);
      adjClose = data(3,:);
      [hi, wid] = size(data);
      if hi == 4
        market(i).decisionSum = data(4,:);
      end
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
    market(i).symbol = symbols{i};
    % market(i).closes = close;
    market(i).adjCloses = adjClose;
    market(i).closes = adjClose;
    market(i).volumes = volume;

    if length(market(i).decisionSum) == 0
      rOpt = 14;
      mOpt = 26;
      aOpt = 20;

      [~, market(i).rsi] = RSI(adjClose, rOpt);
      [~, ~, ~, market(i).aroon] = aroon(adjClose, aOpt);
      [~, ~, market(i).macd] = MACD(adjClose, mOpt, floor(mOpt / 1.8), floor(floor(mOpt / 1.8) / 1.5));
      [~, market(i).obv] = OBV(adjClose, volume);
      [~, ~, market(i).stoch] = stoch(adjClose);
      [~, ~, market(i).sma200_50] = SMA(adjClose);
      market(i).decisionSum =  market(i).rsi + market(i).aroon + market(i).macd + market(i).obv + market(i).stoch + market(i).sma200_50;
      dlmwrite(strcat('Data/', market(i).symbol, '.csv'), market(i).decisionSum, '-append');
    end
  end
i = 1;
while i < length(market)
  if market(i).symbol == 0
    market = [market(1:i-1) market(i+1:end)];
    i = i - 1;
  end
  i = i + 1;
end
% PORTFOLIO SETUP
funds = 100000;
net = funds;
% portfolio = [stock];

today= 365;
%r = length(market);
steps = 365;
delete(h);
h = waitbar(today-365/steps, 'SIMULATING');
for today = 365:730
  waitbar((today-364)/steps,h, today-364);

  for index = 1:length(market)
    % fprintf('%s, %.0f\n ', market(index).symbol, market(index).sharesOwned)
      if (market(index).sharesOwned > 0 && market(index).decisionSum(today) <= -3) || (market(index).sharesOwned > 0 && (market(index).closes(today) / market(index).purchasePrice) >= 1.1)
        %|| (market(index).sharesOwned > 0 && abs(market(index).closes(today) - market(index).purchasePrice) / market(index).purchasePrice >=0.1)
        % fprintf('SELLING %.0f SHARES OF %s FOR $%.2f PER SHARE FOR A RETURN OF $%.2f\n', market(index).sharesOwned, market(index).symbol, market(index).closes(today), market(index).sharesOwned*market(index).closes(today) - market(index).sharesOwned*market(index).purchasePrice)
        funds = funds + market(index).sell(today);
        market(index).sharesOwned = 0;
        % fprintf('%s, %.0f', market(index).symbol, market(index).sharesOwned)
        % net = funds;
        % for index = 1:length(market)
        %   % fprintf('%d %.0f\n', p, market(i).sharesOwned)
        %   net = net + (market(index).sharesOwned * market(index).closes(today));
        % end
        % market(index).sharesOwned
      end
      todaysDecision(index) = market(index).decisionSum(today);
  end
  [~, indexes] = sort(todaysDecision, 'descend');

  for e = 1:length(market)
    temp(e) = market(indexes(e));
    %fprintf('%s %.0f\n', temp(e).symbol, temp(e).decisionSum(today));
  end

  %temp = market(indexes);
  market = temp;

  for i = 1:length(market)
    if net / 10 < funds
      spendingCash = net / 10;
    else
      spendingCash = funds;
    end
    if floor(spendingCash / market(i).closes(today)) > 25
      if market(i).decisionSum(today) >= 4 && market(i).sharesOwned == 0
        market(i).purchasePrice = market(i).closes(today);
        market(i).sharesOwned = market(i).sharesOwned + floor(spendingCash / market(i).purchasePrice);
        % fprintf('BUYING %.0f SHARES OF %s AT $%5.2f PER SHARE\n', (floor(spendingCash / market(i).purchasePrice)), market(i).symbol, market(i).purchasePrice)
        funds = funds - (floor(spendingCash / market(i).purchasePrice)) * market(i).purchasePrice;
        net = funds;
        for p = 1:length(market)
          % fprintf('%d %.0f\n', p, market(i).sharesOwned)
          net = net + (market(p).sharesOwned * market(p).closes(today));
        end
      end
    end
  end

  % BUY UNTIL LESS THAN 1/5 of portfolio is cash
  % disp([market.sharesOwned])
  net = funds;
  for index = 1:length(market)
    % fprintf('%d %.0f\n', p, market(i).sharesOwned)
    net = net + (market(index).sharesOwned * market(index).closes(today));
  end
end
fprintf('%.0f $%10.2f $%10.2f\n', today-365, funds, net);
