function [short, long, predictions] = SMA(close, varargin)

p = inputParser;
addRequired(p, 'close');
addOptional(p, 'shortLength', 50);
addOptional(p, 'longLength', 200);
p.parse(close, varargin{:});
shortLength = p.Results.shortLength;
longLength = p.Results.longLength;

short = tsmovavg(close, 's', shortLength);
long = tsmovavg(close, 's', longLength);

predictions = zeros(1, length(close));
parfor i = 2:length(close)
  if short(i) > long(i) && short(i-1) < long(i-1)
    predictions(i) = -1;
  elseif short(i) < long(i) && short(i-1) > long(i-1)
    predictions(i) = 1;
  end
end
