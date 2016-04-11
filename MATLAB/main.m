function [suggestion, inaccuracy] = main(symbol, close, volume, SIMULATION_LENGTH, varargin)
p = inputParser;
addRequired(p, 'symbol');
addRequired(p, 'close');
addRequired(p, 'volume');
addRequired(p, 'SIMULATION_LENGTH');
addOptional(p, 'RSI_LENGTH', 14);
addOptional(p, 'AROON_LENGTH', 20);
addOptional(p, 'MACD_LONG', 26);

p.parse(symbol, close, volume, SIMULATION_LENGTH, varargin{:});
RSI_LENGTH = p.Results.RSI_LENGTH;
AROON_LENGTH = p.Results.AROON_LENGTH;
MACD_LONG = p.Results.MACD_LONG;
MACD_SHORT = floor(MACD_LONG / 1.8);
MACD_SIG = floor(MACD_SHORT / 1.5);
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
    trend = (aroon_predictions(end) + obv_predictions(end) + stoch_predictions(end));
    trends = zeros(1,length(actuals));
    inaccuracy = 0;
    for i = [1:length(actuals)]
      trends(i) = (aroon_predictions(end) + obv_predictions(end) + stoch_predictions(end));
      if (trends(i) > 2 && actuals(i) == -1) || (trends(i) < -2 && actuals(i) == 1)
        inaccuracy = inaccuracy + 1;
      end
    end
    % suggestions = (RSI_predictions + aroon_predictions + macd_predictions + obv_predictions + stoch_predictions) ./ 5;
    trigger = RSI_predictions(end) + macd_predictions(end);
    if trend > 2 && trigger >= 1
      suggestion = 1;
    elseif trend < -2 && trigger <= -1
      suggestion = -1;
    else
      suggestion = 0;
    end
  end






% prediction = zeros(1, SIMULATION_LENGTH);
% [null, RSI_predictions] = RSI(close, RSI_LENGTH);
% [null, null, arron, aroon_predictions] = aroon(close, AROON_LENGTH);
% [null, null, macd_predictions] = MACD(close, MACD_LONG, MACD_SHORT, MACD_SIG);
%
% predictors(1, :) = RSI_predictions;
% predictors(end, :) = aroon_predictions;
% predictors(end, :) = macd_predictions;
