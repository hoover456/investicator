function [K, D, predictions] = stoch(close, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Stochastic Occilator
%   Momentum Indicator used to see relation of close to high-low range in period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PARSE INPUTS
  p = inputParser;
  addRequired(p, 'close');
  addOptional(p, 'len', 14);
  p.parse(close, varargin{:});
  len = p.Results.len;

% CALCULATE OCCILATOR AND SIGNAL LINE
    K = zeros(1,length(close));
  for i = (len+1:length(close))
    K(i) = (close(i) - min(close(i-len:i)))/(max(close(i-len:i) - min(close(i-len:i)))) * 100;
  end
  K = tsmovavg(K, 's', 3);
  D = tsmovavg(K, 's', 3);

% MAKE PREDICTIONS BASED ON INDICATOR
  predictions = zeros(1,length(K));
  for i = (len:length(K))
    if K(i) < 20
      if K(i) > D(i)
        predictions(i) = 1;
      end
    elseif K(i) > 80
      if K(i) < D(i)
        predictions(i) = -1;
      end
    end
  end
