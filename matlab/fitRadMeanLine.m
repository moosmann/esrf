function cf_ = fitRadMeanLine(x,y,upperLimit,lowerLimit)

if nargin < 4
    lowerLimit = -10;
end

x = x(:);
y = y(:);

% --- Create fit "fit 1"
fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[0 0 lowerLimit,lowerLimit,lowerLimit,lowerLimit,lowerLimit,lowerLimit],'Upper',[upperLimit upperLimit upperLimit,upperLimit,upperLimit,upperLimit,upperLimit,upperLimit]);
ok_ = isfinite(x) & isfinite(y);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end
st_ = [1,0.5,0.1,0.05,0.02,0.01,-0.005,0.002];
set(fo_,'Startpoint',st_);

% ft_ = fittype('b0+b1*x+b2*x^2+b3*x^3+b4*x^4+b5*x^5+b6*x^6+b7*x^7+b8*x^8+b9*x^9',...
%    'dependent',{'y'},'independent',{'x'},...
%    'coefficients',{'b0', 'b1', 'b2', 'b3', 'b4','b5','b6','b7','b8','b9'});

ft_ = fittype('a1*exp(-a2*x)*abs(sin(x))+b1+b2*sqrt(x)+b3*x+b4*sqrt(x)^3+b5*x^2+b6*sqrt(x)^5',...
   'dependent',{'y'},'independent',{'x'},...
   'coefficients',{'a1', 'a2','b1', 'b2', 'b3', 'b4', 'b5','b6'});

% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_,fo_);
