function [RSI, predictions] = RSI(close, varargin)

  OVERBOUGHT = 70;
  OVERSOLD = 30;

  p = inputParser;
  addRequired(p, 'close');
  addOptional(p, 'length', 14);
  parse(p,close,varargin);
  close = p.Results.close;
  len = p.Results.length;

  for i = [2:length(close)]
    change(i-1) = close(i-1) - close(i);
  end

  gain = zeros(1,length(change))';
  loss = zeros(1,length(change))';

  for i = [1:length(change)]
    if change(i) > 1
      gain(i) = change(i);
    elseif change(i) < 1
      loss(i) = abs(change(i));
    end
  end

  gain
  avgGain = mean(gain(1:len));
  avgLoss = mean(loss(1:len));
  RSI(len-1) = (100 - (100 / (1 + (avgGain / avgLoss))));

  for i = [len:length(change)]
    avgGain = avgGain * (len - 1) + gain(i) / len;
    avgLoss = avgLoss * (len - 1) + gain(i) / len;
    RSI(i) = (100 - (100 / (1 + (avgGain / avgLoss))));
  end

  predictions = zeros(1,length(RSI));
  for i  = [1:length(RSI)]'
    if RSI(i) <= OVERSOLD
      predictions(i) = 1;
    elseif RSI(i) >= OVERBOUGHT
      predictions(i) = -1;
    end
  end
