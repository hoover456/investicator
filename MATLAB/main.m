function [suggestion, inaccuracy] = main(symbol, close, volume, SIMULATION_LENGTH, varargin)
p = inputParser;
addRequired(p, 'symbol');
addRequired(p, 'close');
addRequired(p, 'volume');
addRequired(p, 'SIMULATION_LENGTH');
addOptional(p, 'RSI_LENGTH', 14);
addOptional(p, 'AROON_LENGTH', 20);
addOptional(p, 'MACD_LONG', 26);

p.parse(symbol, close, volume, SIMULATION_LENGTH, varargin{:});
  if close(end) == 0
    suggestion = -2;
  else
  rOpt = 14;
  mOpt = 26;
  aOpt = 20;

  [~, RSI_predictions] = RSI(close, rOpt);
  [~, ~, ~, aroon_predictions] = aroon(close, aOpt);
  [~, ~, macd_predictions] = MACD(close, mOpt, floor(mOpt / 1.8), floor(floor(mOpt / 1.8) / 1.5));
  [~, obv_predictions] = OBV(close, volume);
  [~, ~, stoch_predictions] = stoch(close);
  [~, ~, sma_predictions] = SMA(close);
  end
