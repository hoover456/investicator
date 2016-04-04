
%MAIN Summary of this function goes here
%   Detailed explanation goes here
%symbol = input('test: ', 's');

%INITIAL SETUP
clear;
format compact;

% CONSTANTSgraph
symbol = 'AAPL';
SIMULATION_LENGTH = 365;

% GET DATA FROM YAHOO FINANCE
data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbol));
data = data(1:SIMULATION_LENGTH,:);
dates = fliplr(datenum(table2array(data(:,1)))');
open = fliplr(table2array(data(:,2))');
high = fliplr(table2array(data(:,3))');
low = fliplr(table2array(data(:,4))');
close = fliplr(table2array(data(:,5))');
volume = fliplr(table2array(data(:,6))');
adjClose = fliplr(table2array(data(:,7))');



BUY_THRESHOLD = 0.4;
SELL_THRESHOLD = -0.4;

[macd, sig, macd_predictions] = MACD(adjClose);
[RSI, RSI_predictions] = RSI(adjClose);
[null, null, arron, aroon_predictions] = aroon(adjClose, 15);

max = 0;
for PARAM1 = [10:35]
  for PARAM2 = [5:20]
    for PARAM3 = [2:15]
      [macd, sig, macd_predictions] = MACD(adjClose, PARAM1, PARAM2, PARAM3);

      MACD_WEIGHT_X = 0;
      AROON_WEIGHT_X = 0;
      RSI_WEIGHT_X = 0;

      fundsCurrent = 100000;
      sharesCurrent = 0;

      for i  = [1:SIMULATION_LENGTH]
        % -- CALCULATE WEIGHTS
        MACD_WEIGHT = (1 / (1 + (exp(-MACD_WEIGHT_X))));
        AROON_WEIGHT = (1 / (1 + (exp(-AROON_WEIGHT_X))));
        RSI_WEIGHT = (1 / (1 + (exp(-RSI_WEIGHT_X))));

        % -- DETERMINE PREDICTION
        prediction(i) = (macd_predictions(i)  * MACD_WEIGHT + aroon_predictions(i) * AROON_WEIGHT + RSI_predictions(i) * RSI_WEIGHT) / 3;

        % -- BUY
        if prediction(i) >= BUY_THRESHOLD
          sharesCurrent = sharesCurrent + floor(fundsCurrent / close(i));
          fundsCurrent = fundsCurrent -  floor(fundsCurrent / close(i)) * close(i);
        % -- SELL
        elseif prediction (i) <= SELL_THRESHOLD
          fundsCurrent = fundsCurrent + sharesCurrent * close(i);
          sharesCurrent = 0;
        end

        % -- UPDATE PORTFOLIO
        funds(i) = fundsCurrent;
        shares(i) = sharesCurrent;
        value(i) = funds(i) + shares(i) * close(i);
        perc(i) = (value(i) - 100000) / 100000 * 100;

        % -- REWEIGHT PREDICTORS
        if i > floor(SIMULATION_LENGTH / 20)
          if (macd_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || macd_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
            MACD_WEIGHT_X = MACD_WEIGHT_X + 0.1;
          elseif (macd_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || macd_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
            MACD_WEIGHT_X = MACD_WEIGHT_X - 0.1;
          end
          if (aroon_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || aroon_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
            AROON_WEIGHT_X = AROON_WEIGHT_X + 0.1;
          elseif (aroon_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || aroon_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
            AROON_WEIGHT_X = AROON_WEIGHT_X - 0.1;
          end
          if (RSI_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)) || RSI_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)
            RSI_WEIGHT_X = RSI_WEIGHT_X + 0.1;
          elseif (RSI_predictions(i) > 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) < close(i)) || RSI_predictions(i) < 0 & mean(close(i - floor(SIMULATION_LENGTH / 20): i)) > close(i)
            RSI_WEIGHT_X = RSI_WEIGHT_X - 0.1;
          end
        end
      end

      % portfolio = fints(dates', [prediction' funds' shares' value' perc' close']);
      % portfolio = chfield(portfolio, {'series1' 'series2' 'series3' 'series4' 'series5' 'series6'}, {'Prediction' 'Funds' 'Shares' 'Value' 'Percent' 'Close'});
      % chartfts(portfolio);
      if perc(end) > max
        fprintf('PARAM1 %2.0f PARAM2 %2.0f PARAM3 %2.0f Percent Return %3.2f%%\n', PARAM1, PARAM2, PARAM3, perc(end))
        max = perc(end);
      end
      clear('funds')
      clear('shares')
      clear('value')
      clear('perc')
    end
  end
end

% portfolio = fints(dates', [prediction' funds' shares' value' perc' close']);
% portfolio = chfield(portfolio, {'series1' 'series2' 'series3' 'series4' 'series5' 'series6'}, {'Prediction' 'Funds' 'Shares' 'Value' 'Percent' 'Close'});
% chartfts(portfolio);
