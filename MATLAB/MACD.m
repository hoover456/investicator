function [macd, signal, predictions] = MACD(data, varargin)

% CONSTANTS
DEFAULT_LONG = 26;
DEFAULT_SHORT = 14;
DEFAULT_SIGNAL = 9;

% INPUT PARSING
p = inputParser;
addRequired(p, 'data');
addOptional(p, 'long', DEFAULT_LONG);
addOptional(p, 'short', DEFAULT_SHORT);
addOptional(p, 'signal', DEFAULT_SIGNAL);
parse(p,data,varargin{:});
data = p.Results.data;
LONG = p.Results.long;
SHORT = p.Results.short;
SIGNAL = p.Results.signal;

% Calculate MACD
macd = tsmovavg(data, 'e', SHORT) - tsmovavg(data, 'e', LONG);
macd(isnan(macd))=0;
signal = tsmovavg(macd, 'e', SIGNAL);

predictions = zeros(1,length(macd));
parfor i = (1:length(macd))
  if macd(i) > signal(i) && macd(i-1) < signal(i-1)
    predictions(i) = 1;
  elseif macd(i) < signal(i) && macd(i-1) > signal(i-1)
    predictions(i) = -1;
  end
end
