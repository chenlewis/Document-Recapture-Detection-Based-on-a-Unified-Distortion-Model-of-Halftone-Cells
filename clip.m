function xout = clip(xmin, xmax, x)

  if x < xmin
    xout = xmin;
  elseif x > xmax
    xout = xmax;
  else
    xout = x;
  end
end