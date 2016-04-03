function [RSI, predictions] = RSI(close)

  for i = [2:length(close)]
    change(i-1) = close(i-1) - close(i);
  end

  gain = zeroes(length(change));
  loss = zeroes(length(change));

  for i = [1:length(change)]
    if change(i) > 1
      gain(i) = change(i);
    elseif change(i) < 1
      loss(i) = abs(change(i));
    
