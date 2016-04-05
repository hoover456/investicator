function [perc] = main(symbol, varargin)
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
% symbol

SIMULATION_LENGTH = 365;

data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbol));
data = data(1:SIMULATION_LENGTH,:);
dates = fliplr(datenum(table2array(data(:,1)))');
open = fliplr(table2array(data(:,2))');
high = fliplr(table2array(data(:,3))');
low = fliplr(table2array(data(:,4))');
close = fliplr(table2array(data(:,5))');
volume = fliplr(table2array(data(:,6))');
adjClose = fliplr(table2array(data(:,7))');

% CONSTANTS
BUY_THRESHOLD = 0.4;
SELL_THRESHOLD = -0.4;

prediction = zeros(1, SIMULATION_LENGTH);
[null, RSI_predictions] = RSI(close, RSI_LENGTH);
[null, null, arron, aroon_predictions] = aroon(close, AROON_LENGTH);
[null, null, macd_predictions] = MACD(close, MACD_LONG, MACD_SHORT, MACD_SIG);

predictors(1, :) = RSI_predictions;
predictors(end, :) = aroon_predictions;
predictors(end, :) = macd_predictions;

MACD_WEIGHT_X = 0;
AROON_WEIGHT_X = 0;
RSI_WEIGHT_X = 0;

fundsCurrent = 100000;
sharesCurrent = 0;
fundsHeld = 0;

for i  = [1:SIMULATION_LENGTH]
  % -- CALCULATE WEIGHTS
  % MACD_WEIGHT = (1 / (1 + (exp(-MACD_WEIGHT_X))));
  % AROON_WEIGHT = (1 / (1 + (exp(-AROON_WEIGHT_X))));
  % RSI_WEIGHT = (1 / (1 + (exp(-RSI_WEIGHT_X))));

  % -- DETERMINE PREDICTION
  prediction(i) = mean(predictors(:,i));

  % -- BUY
  if prediction(i) >= BUY_THRESHOLD
    if sharesCurrent >= 0
      sharesCurrent = sharesCurrent + floor(fundsCurrent / close(i));
      fundsCurrent = fundsCurrent -  floor(fundsCurrent / close(i)) * close(i);
    end
  % -- SELL
  elseif prediction (i) <= SELL_THRESHOLD
    if sharesCurrent > 0
      fundsCurrent = fundsCurrent + sharesCurrent * close(i);
      sharesCurrent = 0;
    end
  end

  % -- UPDATE PORTFOLIO
  funds(i) = fundsCurrent - fundsHeld;
  shares(i) = sharesCurrent;
  value(i) = funds(i) + shares(i) * close(i);
  perc(i) = (value(i) - 100000) / 100000 * 100;

  % -- REWEIGHT PREDICTORS
  % if i > floor(SIMULATION_LENGTH / 20)
  %   if (macd_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || macd_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
  %     MACD_WEIGHT_X = MACD_WEIGHT_X + 0.1;
  %   elseif (macd_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || macd_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
  %     MACD_WEIGHT_X = MACD_WEIGHT_X - 0.1;
  %   end
  %   if (aroon_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || aroon_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
  %     AROON_WEIGHT_X = AROON_WEIGHT_X + 0.1;
  %   elseif (aroon_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || aroon_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
  %     AROON_WEIGHT_X = AROON_WEIGHT_X - 0.1;
  %   end
  %   if (RSI_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || RSI_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
  %     RSI_WEIGHT_X = RSI_WEIGHT_X + 0.1;
  %   elseif (RSI_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || RSI_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
  %     RSI_WEIGHT_X = RSI_WEIGHT_X - 0.1;
  %   end
  % end
end
perc = perc(SIMULATION_LENGTH);
