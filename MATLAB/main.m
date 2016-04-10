function [suggestion, close, accuracies] = main(symbol, varargin)
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
    % lens = floor(SIMULATION_LENGTH/40);
    for i = [1:SIMULATION_LENGTH-10]
      if close(i+10) > close(i)
        actuals(i) = 1;
      elseif close(i+10) < close(i)
        actuals(i) = -1;
      else
        actuals(i) = 0;
      end
    end
    %
    % r = zeros(1,20);
    % parfor RSI_LENGTH = [5:20]
    %   [null, RSI_predictions] = RSI(close, RSI_LENGTH);
    %   r(RSI_LENGTH) = sum(RSI_predictions == actuals);
    % end
    % [a,b] = max(r);
    % fprintf('%s, r %2.0f, len %2.0f\n', symbol, a, b)
    % [RSI_accuracy,I] = max(r);
    % rOpt = I;

    % r = zeros(1,30);
    % parfor AROON_LENGTH = [10:30]
    %   [null, null, arron, aroon_predictions] = aroon(close, AROON_LENGTH);
    %   r(AROON_LENGTH) = sum(aroon_predictions == actuals);
    % end
    % [a,b] = max(r);
    % % fprintf('%s, a %2.0f, len %2.0f\n', symbol, a, b)
    % [aroon_accuracy,I] = max(r);
    % aOpt = I;
    %
    % r = zeros(1,32);
    % parfor MACD_LONG = [15:32]
    %   MACD_SHORT = floor(MACD_LONG / 1.8);
    %   MACD_SIG = floor(MACD_SHORT / 1.5);
    %   [null, null, macd_predictions] = MACD(close, MACD_LONG, MACD_SHORT, MACD_SIG);
    %   r(MACD_LONG) = sum(macd_predictions == actuals);
    % end
    % [a,b] = max(r);
    % % fprintf('%s, m %2.0f, len %2.0f\n', symbol, a, b)
    % [macd_accuracy,I] = max(r);
    % mOpt = I;
    rOpt = 14;
    mOpt = 26;
    aOpt = 20;

    [null, RSI_predictions] = RSI(close, rOpt);
    [null, null, null, aroon_predictions] = aroon(close, aOpt);
    [null, null, macd_predictions] = MACD(close, mOpt, floor(mOpt / 1.8), floor(floor(mOpt / 1.8) / 1.5));
    [null, obv_predictions] = OBV(close, volume);
    [null, null, stoch_predictions] = stoch(close);
    suggestion = (RSI_predictions(end) + aroon_predictions(end) + macd_predictions(end) + obv_predictions(end) + stoch_predictions(end)) / 5;
    suggestions = zeros(1,length(actuals));
    for i = [1:length(actuals)]
      suggestions(i) = (RSI_predictions(i) + aroon_predictions(i) + macd_predictions(i) + obv_predictions(i) + stoch_predictions(i)) / 5;
    end
    % suggestions = (RSI_predictions + aroon_predictions + macd_predictions + obv_predictions + stoch_predictions) ./ 5;

    rsi_accuracy = sum(RSI_predictions == actuals);
    aroon_accuracy = sum(aroon_predictions == actuals);
    macd_accuracy = sum(macd_predictions == actuals);
    obv_accuracy = sum(obv_predictions == actuals);
    stoch_accuracy = sum(stoch_predictions == actuals);
    mean_accuracy = (rsi_accuracy + aroon_accuracy + macd_accuracy + obv_accuracy + stoch_accuracy) / 5;
    predictions_accuracy = 0;
    for i =[1:length(suggestions)]
      if (suggestions(i) > 0.5 && actuals(i) > 0) || (suggestions(i) < -0.5 && actuals(i) < 0)
        predictions_accuracy = predictions_accuracy + 1;
      % else
      %   predictions_accuracy = predictions_accuracy - 1;
      end
    end
    accuracies =  {symbol rsi_accuracy aroon_accuracy macd_accuracy obv_accuracy stoch_accuracy mean_accuracy predictions_accuracy};
    fid2 = fopen('accuracies.csv', 'at');
    fprintf(fid2, '%s,', accuracies{1});
    fclose(fid2);
    dlmwrite('accuracies.csv',accuracies(2:end), '-append');
  end
catch exception
  disp(exception)
  fprintf('Could Not Retrieve Data for %s, please remove from list\n', symbol)
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
