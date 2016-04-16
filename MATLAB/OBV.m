function [obv, predictions] = OBV(close, volume)

  % CALCULATION
  obv = zeros(1, length(close));
  for i = (2:length(volume))
    if close(i) > close(i-1)
      obv(i) = obv(i-1) + volume(i);
    elseif close(i) < close(i-1)
      obv(i) = obv(i-1) - close(i);
    else
      obv(i) = obv(i-1);
    end
  end

  % PREDICTIONS
  predictions = zeros(1,length(obv));
  for i = (11:length(obv))
    if obv(i) > obv (i-5)
      predictions(i) = 1;
    elseif obv(i) < obv(i-5)
      predictions(i) = -1;
    end
  end
end
