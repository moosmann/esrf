x=200:350;
y=yOut(1,x);

x=x(:)/maxVal;
y=y(:)/max(y(:));

fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[0,0,0,0],'Upper',[10,1,10,100]);
ok_ = isfinite(x) & isfinite(y);

if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end

st_ = [1,0.0001,1,2];
set(fo_,'Startpoint',st_);

% ft_ = fittype('b0+b1*x+b2*x^2+b3*x^3+b4*x^4+b5*x^5+b6*x^6+b7*x^7+b8*x^8+b9*x^9',...
%    'dependent',{'y'},'independent',{'x'},...
%    'coefficients',{'b0', 'b1', 'b2', 'b3', 'b4','b5','b6','b7','b8','b9'});

ft_ = fittype('a1*exp(-a2*x^2)*abs(sin(c1*x^2))+b1',...
   'dependent',{'y'},'independent',{'x'},...
   'coefficients',{'a1','a2','c1','b1'});

% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_,fo_);