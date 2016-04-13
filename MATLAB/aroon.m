function [up, down, occilator, predictions] = aroon(data, varargin)

% CONSTANTS
PREDICT_UP = 25; % occilator value above which prediction is price increase
PREDICT_DOWN = -25; % occilator value above whihc prediction is price decrease
DEFAULT_LENGTH = 20;

% INPUT PARSING
p = inputParser;
addRequired(p, 'data');
addOptional(p, 'length', DEFAULT_LENGTH);
parse(p,data,varargin{:});
data = p.Results.data;
l = p.Results.length;

up = zeros(length(data));
down = zeros(length(data));

% Calculate up, down, and occilator from data
for i = l+1:length(data)
  k = find(data(i-l:i) == max(data(i-l:i)));
  k = k(1);
  up(i) = (l - k) / l * 100;
  k = find(data(i-l:i) == min(data(i-l:i)));
  k = k(1);
  down(i) = (l - k) / l * 100;
  occilator = up - down;
end

predictions = zeros(1,length(occilator));
for i = 1:length(occilator)
  if occilator(i) >= PREDICT_UP
    predictions(i) = 1;
  elseif occilator(i) <= PREDICT_DOWN
    predictions(i) = -1;
  end
end
