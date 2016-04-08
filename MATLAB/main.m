function [suggestion, close] = main(symbol, varargin)
p = inputParser;
addRequired(p, 'symbol');
addOptional(p, 'RSI_LENGTH', 14);
addOptional(p, 'AROON_LENGTH', 20);
addOptional(p, 'MACD_LONG', 26);

p.parse(symbol,varargin{:});
RSI_LENGTH = p.Results.RSI_LENGTH;
AROON_LENGTH = p.Results.AROON_LENGTH;
MACD_LONG = p.Results.MACD_LONG;
MACD_SHORT = floor(MACD_LONG / 1.8);
MACD_SIG = floor(MACD_SHORT / 1.5);
close = 0;
try
  data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbol));
  if height(data) >= 365
    SIMULATION_LENGTH = 365;
  else
    SIMULATION_LENGTH = height(data);
  end
  data = data(1:SIMULATION_LENGTH,:);
  dates = fliplr(datenum(table2array(data(:,1)))');
  open = fliplr(table2array(data(:,2))');
  high = fliplr(table2array(data(:,3))');
  low = fliplr(table2array(data(:,4))');
  close = fliplr(table2array(data(:,5))');
  volume = fliplr(table2array(data(:,6))');
  adjClose = fliplr(table2array(data(:,7))');
  if close(end) == 0
    suggestion = -2;
  else

    actuals = zeros(1,SIMULATION_LENGTH);
    avgLength = floor(SIMULATION_LENGTH/20);
    for i = [avgLength+1:SIMULATION_LENGTH]
      if mean(close(i-avgLength:i)) > close(i)
        actuals(i) = 1;
      elseif mean(close(i-avgLength:i)) < close(i)
        actuals(i) = -1;
      else
        actuals(i) = 0;
      end
    end

    r = zeros(1,21);
    parfor RSI_LENGTH = [10:20]
      [null, RSI_predictions] = RSI(close, RSI_LENGTH);
      r(RSI_LENGTH) = length(find(RSI_predictions == actuals));
    end
    [RSI_accuracy,I] = max(r);
    rOpt = I;

    r = zeros(1,30);
    parfor AROON_LENGTH = [15:30]
      [null, null, arron, aroon_predictions] = aroon(close, AROON_LENGTH);
      r(AROON_LENGTH) = length(find(aroon_predictions == actuals));
    end
    [aroon_accuracy,I] = max(r);
    aOpt = I;

    r = zeros(1,39);
    parfor MACD_LONG = [18:32]
      MACD_SHORT = floor(MACD_LONG / 1.8);
      MACD_SIG = floor(MACD_SHORT / 1.5);
      [null, null, macd_predictions] = MACD(close, MACD_LONG, MACD_SHORT, MACD_SIG);
      r(MACD_LONG) = length(find(macd_predictions == actuals));
    end
    [macd_accuracy,I] = max(r);
    mOpt = I;

    [null, RSI_predictions] = RSI(close, rOpt);
    [null, null, null, aroon_predictions] = aroon(close, aOpt);
    [null, null, macd_predictions] = MACD(close, mOpt, floor(mOpt / 1.8), floor(floor(mOpt / 1.8) / 1.5));
    [null, obv_predictions] = OBV(close, volume);
    suggestion = (RSI_predictions(end) + aroon_predictions(end) + macd_predictions(end) + obv_predictions(end)) / 4;

    obv_accuracy = sum(obv_predictions == actuals);

    parameters =  {symbol RSI_LENGTH AROON_LENGTH MACD_LONG};
    accuracies =  {symbol RSI_accuracy aroon_accuracy macd_accuracy obv_accuracy};
    fid1 = fopen('parameters.csv', 'at');
    fid2 = fopen('accuracies.csv', 'at');
    fprintf(fid1, '%s,', parameters{1});
    fprintf(fid2, '%s,', accuracies{1});
    fclose(fid1);
    fclose(fid2);
    parameters(2:end);
    dlmwrite('parameters.csv',parameters(2:end), '-append');
    dlmwrite('accuracies.csv',accuracies(2:end), '-append');
  end
catch exception
  %fprintf('Could Not Retrieve Data for %s, please remove from list\n', symbol)
  suggestion = -2;
end






% prediction = zeros(1, SIMULATION_LENGTH);
% [null, RSI_predictions] = RSI(close, RSI_LENGTH);
% [null, null, arron, aroon_predictions] = aroon(close, AROON_LENGTH);
% [null, null, macd_predictions] = MACD(close, MACD_LONG, MACD_SHORT, MACD_SIG);
%
% predictors(1, :) = RSI_predictions;
% predictors(end, :) = aroon_predictions;
% predictors(end, :) = macd_predictions;
