function [up, down, occilator, predictions] = aroon(data, varargin)

% CONSTANTS
PREDICT_UP = 20; % occilator value above which prediction is price increase
PREDICT_DOWN = -20; % occilator value below which prediction is price decrease
DEFAULT_LENGTH = 20;

% INPUT PARSING
p = inputParser;
addRequired(p, 'data');
addOptional(p, 'length', DEFAULT_LENGTH);
parse(p,data,varargin{:});
data = p.Results.data;
l = p.Results.length;

up = zeros(1,length(data));
down = zeros(1,length(data));

% Calculate up, down, and occilator from data
for i = l+1:length(data)
  [~, k] = max(data(i-l:i));
  up(i) = (l - k) / l * 100;
  [~, j] = min(data(i-l:i));
  down(i) = (l - j) / l * 100;
  occilator = up - down;
end

predictions = zeros(1,length(occilator));
parfor i = 1:length(occilator)
  if occilator(i) >= PREDICT_UP
    predictions(i) = 1;
  elseif occilator(i) <= PREDICT_DOWN
    predictions(i) = -1;
  end
end
