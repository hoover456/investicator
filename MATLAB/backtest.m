function backtest(listName)


  symbols = dataread('file', listName, '%s', 'delimiter', '\n'); % Read in list of symbols

  % Get 2 years data for each symbol
  steps = length(symbols);
  h = waitbar(0/steps, 'GETTING DATA');
SIMULATION_LENGTH = 730;
  for i = 1:steps
    waitbar(i/steps, h, strcat(num2str(i), '/', num2str(steps)));
    market(i) = stock;
    if exist(strcat('Data/',symbols{i}, '.csv'), 'file') == 2
      data = dlmread(strcat('Data/',symbols{i}, '.csv'));
      close = data(1,:);
      volume = data(2,:);
      adjClose = data(3,:);
      [hi, wid] = size(data);
      % if hi == 4
      %  market(i).decisionSum = data(4,:);
      % end
    else
      data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbols{i}));
      if height(data) < 730
        continue;
      else
        data = data(1:SIMULATION_LENGTH,:);
        close = fliplr(table2array(data(:,5))');
        volume = fliplr(table2array(data(:,6))');
        adjClose = fliplr(table2array(data(:,7))');
        fid = fopen(strcat('Data/',symbols{i},'.csv'),'wt');
        fclose(fid);
        dlmwrite(strcat('Data/',symbols{i},'.csv'), [close; volume; adjClose]);
      end
    end
    market(i).symbol = symbols{i};
    % market(i).closes = close;
    market(i).adjCloses = adjClose;
    market(i).closes = adjClose;
    market(i).volumes = volume;

    if length(market(i).decisionSum) == 0
      rOpt = 14;
      mOpt = 26;
      aOpt = 25;

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
market = market(1:end-1);
% PORTFOLIO SETUP
funds = 100000;
% shortFunds = 0;
net = funds;

today= 365;
steps = 365;
delete(h);
h = waitbar(today-365/steps, 'SIMULATING');
for today = 365:730
  waitbar((today-364)/steps,h, today-364);

% --- SELL FROM PORTFOLIO ---
  for index = 1:length(market)

      if (market(index).sharesOwned > 0 && market(index).decisionSum(today) <= -3) || (market(index).sharesOwned > 0 && (market(index).closes(today) / market(index).purchasePrice) >= 1.5) || (market(index).sharesOwned > 0 && (market(index).closes(today) / market(index).purchasePrice) <= 0.98)
        fprintf('SELLING %5.0f SHARES OF %s FOR $%.2f PER SHARE FOR A RETURN OF $%.2f\n', market(index).sharesOwned, market(index).symbol, market(index).closes(today), (market(index).sharesOwned*market(index).closes(today)) - (market(index).sharesOwned*market(index).purchasePrice))
        funds = funds + market(index).sell(today);
        market(index).sharesOwned = 0;
      end
      todaysDecision(index) = market(index).decisionSum(today);
  end

% --- COVER SHORT FROM PORTFOLIO
  % for index = 1:length(market)
  %   if (market(index).sharesShort ~= 0 && market(index).decisionSum(today) >= 3) || (market(index).sharesShort ~= 0 && market(index).closes(today) / market(index).shortPrice >= 1.2)
  %     fprintf('COVERING SHORT OF %s FOR $%.2f PER SHARE, RETURN $%.2f\n', market(index).symbol, market(index).closes(today), market(index).sharesShort * (market(index).closes(today) - market(index).shortPrice))
  %     funds = funds + market(index).sharesShort * (market(index).closes(today) - market(index).shortPrice);
  %     market(index).sharesShort = 0;
  %     net = funds;
  %     for index = 1:length(market)
  %       net = net + (market(index).sharesOwned * market(index).closes(today) + (market(index).sharesShort * (market(index).closes(today) - market(index).shortPrice)));
  %     end
  %   end
  % end

% --- SORT MARKET BY DECISION SUM
  [~, indexes] = sort(todaysDecision, 'descend');
  temp = market(indexes);
  market = temp;

% --- RECALCULATE NET FUNDS
  net = funds;
  for index = 1:length(market)
  net = net + (market(index).sharesOwned * market(index).closes(today));
  end

  % % --- SHORT SELL TODAY
  %   for i = length(market):-1:1
  %     if net / 8 < funds
  %       spendingCash = net / 8;
  %     else
  %       spendingCash = funds;
  %     end
  %     if (spendingCash / market(i).closes(today)) > 25
  %       if market(i).decisionSum(today) <= -4 && market(i).sharesShort == 0
  %         market(i).shortPrice = market(i).closes(today);
  %         market(i).sharesShort = market(i).sharesShort + floor(spendingCash / market(i).shortPrice);
  %         fprintf('SHORT SELLING %.0f SHARES OF %s FOR $%.2f PER SHARE, TOTAL $%.2f\n', market(i).sharesShort, market(i).symbol, market(i).shortPrice, market(i).shortPrice*market(i).sharesShort)
  %         funds = funds - floor(spendingCash / market(i).shortPrice) * market(i).shortPrice;
  %         net = funds;
  %         for p = 1:length(market)
  %           net = net + (market(p).sharesOwned * market(p).closes(today)) + (market(p).sharesShort * (market(p).closes(today) - market(p).shortPrice));
  %         end
  %       end
  %     end
  %   end
% --- BUY FOR TODAY
  for i = 1:length(market)
    if net / 5 < funds
      spendingCash = net / 5;
    else
      spendingCash = funds;
    end
    if floor(spendingCash / market(i).closes(today)) > 25
      if market(i).decisionSum(today) >= 5% && market(i).sharesOwned == 0
        market(i).purchasePrice = market(i).closes(today);
        market(i).sharesOwned = market(i).sharesOwned + floor(spendingCash / market(i).purchasePrice);
        fprintf('BUYING %5.0f SHARES OF %s AT $%5.2f PER SHARE\n', (floor(spendingCash / market(i).purchasePrice)), market(i).symbol, market(i).purchasePrice)
        funds = funds - (floor(spendingCash / market(i).purchasePrice)) * market(i).purchasePrice;
        net = funds;
        for p = 1:length(market)
          net = net + (market(p).sharesOwned * market(p).closes(today));
        end
      end
    end
  end

% --- CALCULATE NET FUNDS
  net = funds;
  for index = 1:length(market)
    net = net + (market(index).sharesOwned * market(index).closes(today));
  end
end

delete(h);
fprintf('%.0f $%10.2f $%10.2f\n', today-365, funds, net);
