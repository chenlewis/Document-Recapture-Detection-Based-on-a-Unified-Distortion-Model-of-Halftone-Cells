
function [xSqrtGlobal, ySqrtGlobal, cGlobal, minLoss] = ...
            optimize_parameters_three_var(halftone_dot_width_mean,...
                                          sigma_b,...
                                          sigma_a,...
                                          rough_num_dots_horiz,...
                                          peak_value,...
                                          peak_freq,...
                                          num_peaks_optimization, ~, fileName)
  N = rough_num_dots_horiz;

  % the number of peaks should be only a halftone of the total number of peaks
  E = peak_value(1:num_peaks_optimization);
  cos_sum = N^2-N;

  % the frequencies that are used in optimization
  f = peak_freq(1:num_peaks_optimization);
  
%   ka1 = N-N.*cos(2.*pi.*f.*c).*exp(-2.*sigma_b.^2*(f.*pi).^2);
%   ka2 = 2.*sin(pi.*f.*c).^2.*exp(-sigma_b.^2*(f.*pi).^2).*cos_sum;
%   
%   kb1 = N.*cos(2.*pi.*f.*c);
%   kb2 = 2.*cos_sum.*sin(pi.*f.*c).^2.*exp(-4.*sigma_a.^2*(f.*pi).^2);
%   
%   kc1 = N - N.*exp(-2.*sigma_b.^2*(f.*pi).^2);
%   kc2 = 2.*N.*exp(-2.*sigma_b.^2*(f.*pi).^2) + 2.*cos_sum.*...
%         exp(-4.*sigma_a.^2.*(f.*pi).^2).*exp(-sigma_b.^2.*(f.*pi).^2);
%   

%   objFunc = @(x,y,c) ...
%           mean(abs(log((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2) + 2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)...
%                     ./(2.*sin(pi.*f).^2.*E))));
       
%   objFunc = @(x,y,c) ...
%           mean(((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
%                  2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./(2.*(pi.*f).^2) - E).^2);
  
  % the objective function
  objFunc = @(x,y,c) ...
          mean((log((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
                     2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./...
                     (2.*sin(pi.*f).^2.*E))).^2);
                    
%   % the derivtives are in terms of x
%   df_dsigma_a_square = ...
%       @(x,y,c) mean(2.*log((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
%                             2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y)*(f.*pi).^2).*cos_sum)./(2.*(f.*pi).^2.*E)).*...
%                       ((-8.*(f.*pi).^2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./...
%                       (N-N.*cos(2.*pi.*f.*c).*exp(-2.*y*(f.*pi).^2)+2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)));
%               
%   df_dsigma_b_square = ...
%       @(x,y,c) mean(2.*log((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
%                     2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./...
%                    (2.*(f.*pi).^2.*E)).*...
%                    (2.*N.*(f.*pi).^2.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)-...
%                     2.*sin(pi.*f.*c).^2.*(f.*pi).^2.*cos_sum.*exp(-(4.*x+y).*(f.*pi).^2))./...
%                    (N.*(1-cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2))+...
%                     2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum));
%    
%   df_dc = ...
%       @(x,y,c) mean(2.*log((N-N.*cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
%                            2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./...
%                            (2.*(f.*pi).^2.*E)).*...
%                     (2.*pi.*f.*N.*sin(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2)+...
%                      2.*pi.*f.*sin(2.*pi.*f.*c).*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum)./...
%                     (N.*(1-cos(2.*pi.*f.*c).*exp(-2.*y.*(f.*pi).^2))+...
%                      2.*sin(pi.*f.*c).^2.*exp(-(4.*x+y).*(f.*pi).^2).*cos_sum));
% 
%   loss = zeros(1, 50000);
  
  %% brute force
  
  % these are the initial guess
  x = sigma_a^2;
  x_lower = x / 10;
  x_upper = x + 0.5;
  
  disp(['x lower: ' num2str(sqrt(x_lower))]);
  
  y = sigma_b^2;
  y_lower = x_lower * 4;
  y_upper = x_upper * 4 + 0.5;      % make sure it has valid value
  
  c = halftone_dot_width_mean;
  c_upper = c + 3;
  c_lower = c - 3;
  
  [xMesh, yMesh, cMesh] = meshgrid(x_lower:0.025:x_upper, y_lower:0.025:y_upper, c_lower:0.25:c_upper);
  lossValueBruteForce = 100 .* ones(size(xMesh));
  
  for i = 1:length(xMesh(:))
    % here is some trick
    if yMesh(i) < 4 * xMesh(i) || yMesh(i) > 4 * xMesh(i) + 0.5
      continue
    else
      lossValueBruteForce(i) = objFunc(xMesh(i), yMesh(i), cMesh(i));
    end
  end
  
  minLoss = min(lossValueBruteForce(:));
  globalMinIdx = find(lossValueBruteForce(:) == minLoss, 1);
  xSqrtGlobal = sqrt(xMesh(globalMinIdx));
  ySqrtGlobal = sqrt(yMesh(globalMinIdx));
  cGlobal = cMesh(globalMinIdx);
  
  if isempty(xSqrtGlobal)
    xSqrtGlobal = sigma_a;
    ySqrtGlobal = 2 * xSqrtGlobal;
    cGlobal = halftone_dot_width_mean;
  end
  
%   x = ga(objFunc,nvars,A,b)
  
  try
    disp(['losee before: ' num2str(objFunc(x, y, c)) ' loss after: ' num2str(lossValueBruteForce(globalMinIdx))]);
%     disp(['before: ' num2str(sigma_a) ' after: ' num2str(xSqrtGlobal)]);
    sigma_a
    xSqrtGlobal
%     ySqrtGlobal / xSqrtGlobal
  catch
    disp(fileName);
  end
  
  clear lossValueBruteForce;
  
%% gradient descent
%   gamma = 2;
%   TOL = 1e-12;
%   sigma_a
%   x = sigma_a^2;
%   y = sigma_b^2;
%   c = halftone_dot_width_mean;
  
%   % iterate for 100 times
%   for opt_i = 1 : 100000
%     
%     % error
%     loss(opt_i) = objFunc(x,y,c);    
%     
%     % the 2nd run and onwards
%     if opt_i > 1
%       
%       x_prev = x;
%       y_prev = y;
%       c_prev = c;
%       dF_prev = dF;
%       
%       update = [x; y; c] - gamma .* dF;
%       x = update(1);
%       x = clip(x_lower, x_upper, x);
%       
%       y = update(2);
%       y = clip(x * 3, y_upper, y);
%       
%       c = update(3);
%       c = clip(c_lower, c_upper, c);
%       
%       dF = [df_dsigma_a_square(x,y,c);
%             df_dsigma_b_square(x,y,c);
%             df_dc(x,y,c)];
%               
%       gamma = [x - x_prev y - y_prev c - c_prev] * (dF - dF_prev) / norm(dF - dF_prev, 2);
%       
%       if (abs(x - x_prev) < TOL) && (abs(y - y_prev) < TOL) && (abs(c - c_prev) < TOL)
%         loss_value = objFunc(x,y,c);
%         break;
%       end
%       loss_value = objFunc(x,y,c);
%       
%     % the first run
%     else
%      
%       dF = [df_dsigma_a_square(x,y,c);
%             df_dsigma_b_square(x,y,c);
%             df_dc(x,y,c)];
%           
%       update = [x; y; c] - gamma .* dF;
%       
%       % update xyc
%       x = update(1);
%       x = clip(x_lower, x_upper, x);
%       
%       y = update(2);
%       y = clip(x * 4, y_upper, y);
%       
%       c = update(3);
%       c = clip(c_lower, c_upper, c);
%       
%       dF = [df_dsigma_a_square(x,y,c);
%             df_dsigma_b_square(x,y,c);
%             df_dc(x,y,c)];
% 
%     end
%   end
%   x_sqrt = sqrt(x)
%   y_sqrt = sqrt(y);
%   disp(['loss from gradient descent is: ' num2str(loss(opt_i))]);
%   %% plotting the first derivatives of the objective
%   if plot_control
%     range_of_x = 0 : 0.1 : 2;
%     if plot_control
%       df_dsigma_x_square_values = zeros(1, length(range_of_x));
%       figure;
%       for i=1:length(range_of_x)
%         df_dsigma_x_square_values(i) = df_dsigma_a_square(range_of_x(i),y,c);
%       end
%       plot(range_of_x, df_dsigma_x_square_values);
%       hold on;
%       plot(x, df_dsigma_a_square(x,y,c), 'ro');
%       title('the 1st derivative of x');
%       hold off;
%     end
% 
%     range_of_y = 0 : 0.1 : 10;
%     if plot_control
%       df_dsigma_b_square_values = zeros(1, length(range_of_y));
%       figure;
%       for i=1:length(range_of_y)
%         df_dsigma_b_square_values(i) = df_dsigma_b_square(x,range_of_y(i),c);
%       end
%       plot(range_of_y, df_dsigma_b_square_values);
%       hold on;
%       plot(y, df_dsigma_b_square(x,y,c), 'ro');
%       title('the 1st derivative of y');
%       hold off;
%     end
% 
%     range_of_c = halftone_dot_width_mean - 0.5 : 0.01 : halftone_dot_width_mean + 0.5;
%     if plot_control
%       figure;
%       df_dc_values = zeros(1, length(range_of_c));
%       for i=1:length(range_of_c)
%         df_dc_values(i) = df_dc(x,y,range_of_c(i));
%       end
%       plot(range_of_c, df_dc_values);
%       hold on;
%       plot(c, df_dc(x,y,c), 'ro');
%       title('the 1st derivative of c');
%       hold off;
%     end
%   end
%   %% show the loss function
%   if plot_control
%     figure;
%     stem(1:length(loss),loss,'r','LineWidth',1);
%   end
 
end

