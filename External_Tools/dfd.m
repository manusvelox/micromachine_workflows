function [derivative] = dfd(var,dim,accuracy,order,d_dim,type)
%% DERIVATIVE FINITE DIFFERENCE
% The code provides derivates of two dimensional equi-spaced variables
% using finite difference formulation. 
% Accuracy upto 8th order accurate for central and 6th order accurate for one sided (backward or forward).
% Only and second derivatives can be calculated. 
% Derivatives at edge points are calculated at maximum possible accuracy
% BCs have to enforced outside this code
% var:          Two dimensional variable 
% dim:          Dimension along which the derivative is to be calculated
% accuracy:     Accuracy of finite difference formulation; 1,2..6 for one
%               sided, and 2,4,6,8 for central difference schemes.
% order:        Order of derivative: 1 for first derivative (e.g. du/dx) and 2
%               for second order derivative (e.g. d2u/dx2)
% d_dim:        spacing along the dimension specified in "dim"
% type:         a string specifying the type of formulation
%               'central' or 'forward' or 'backward'
%% Example 1:   dfd(u,1,3,1,0.01,'forward')
%               First derivative of u along 1st dimension. Forward,
%               one-sided, 3rd order accurate finite difference
%               formulation. A separation of 0.01 between
%               consecutive locations. 
%% Example 2:   dfd(u,2,6,2,0.05); OR dfd(u,2,6,2,0.05,'central');
%               Second derivative of u along 2nd dimension. Central, 
%               6th order accurate finite difference formulation. 
%               A separation of 0.05 between consecutive locations. 
%% Example 3:   dfd(u,2,6,2,0.01,'central-with-one-sided-edges');
%               Second derivative of u along 2nd dimension.  
%               6th order accurate central finite difference formulation at the inner points.
%               6th order accurate one - sided finite difference formulation at the edge points.
%               A separation of 0.01 between consecutive locations. 
%
% Therefore, 5 or 6 inputs are required
% Author: Tapish Agarwal
% Last update: April 23, 2020, Technion, Haifa, Israel

switch nargin
    case 5;        type = 'central'; 
    case {1,2,3,4};        error('incorrect Number of inputs');
end
%%
% Forward and backward can be bunched together by defining a variable
% direction
% direction:    For one-sided formulation, direction is given as 1 for
%               forward differencing, and -1 for backward differencing.
if strcmp(type, 'forward'); type = 'one-sided'; direction = 1; end
if strcmp(type, 'backward'); type = 'one-sided'; direction = -1; end
% 
if strcmp(type, 'central-with-one-sided-edges'); type_original = type; type = 'central'; end
% Read coefficient matrix
coeff = fd_coefficient_matrix(type,order); 
n = size(var,dim); % number of elements along desired dimension
%% check for errors
if n< accuracy;                                     error('Length of array along the dimension should be more than the derivative accuracy');end
if strcmp(type, 'central')  && rem(accuracy,2)~=0;  error('For central differencing we can only get even number accuracy'); end
if strcmp(type, 'central')  && accuracy>8;          error('Sorry, this code can not calculate at this accuracy'); end
if strcmp(type, 'one-sided')&& accuracy>6;          error('Sorry, this code can not calculate at this accuracy'); end
if accuracy<1;                                      error('Please correct the order of accuracy');    end
if order>2;                                         error('We can not calculate higher than second order derivative');    end
%% Main part of the code where derivatives are calculated
%% First let us find Positions at which desired accuracy derivative can be calculated
% pfa = positions with full accuracy; 
% pra = positions reduced accuracy; 
if strcmp(type, 'central')
    pfa = accuracy/2+1:n-accuracy/2;    pra = [1:accuracy/2 n-accuracy/2+1:n];
elseif strcmp(type, 'one-sided') 
    if      direction == 1;     pfa = 1:n-accuracy-order+1;     pra = n-accuracy+2-order:n; 
    elseif  direction == -1;    pfa = accuracy+order:n;         pra = accuracy+order-1:-1:1; end
end
%% Let us calculate derivative at locations which permit full accuracy
if dim == 2; var = var.'; end
% initialize size of derivative 
derivative = zeros(size(var));
if strcmp(type, 'central')
    derivative(pfa,:) = derivative_central(var,pfa,accuracy,order,d_dim,coeff);
% reduced accuracy at side points
% e.g. for 4th order accurate forward derivative..2nd order derivates for
% 2nd and (n-1)th point; 
% BCs are required for 1st and nth points, which will have to be imposed
% outside this code.
    for cnt_pra = 1:length(pra)/2-1
        derivative([pra(cnt_pra+1) pra(end-cnt_pra)],:) = derivative_central(var,[pra(cnt_pra+1) pra(end-cnt_pra)],cnt_pra*2,order,d_dim,coeff);
    end
elseif strcmp(type, 'one-sided')
    derivative(pfa,:) = derivative_one_sided(var,pfa,accuracy,order,d_dim,direction,coeff);
% reduced accuracy at side points; 
% e.g. for 3rd order accurate forward derivative..2nd order derivate for
% (n-2)th point and 1st order derivative for (n-1)th point. nth point will have to
% be imposed later as BC (outside this code)
if order ==1    
    for cnt_pra = 1:length(pra)-1
        derivative(pra(cnt_pra),:) = derivative_one_sided(var,pra(cnt_pra),accuracy-cnt_pra,order,d_dim,direction,coeff);
    end
elseif order ==2
    for cnt_pra = 1:length(pra)-2
        derivative(pra(cnt_pra),:) = derivative_one_sided(var,pra(cnt_pra),accuracy-cnt_pra,order,d_dim,direction,coeff);
    end
end
end
% edge calculations for the special case of centrel differncing with edge
% one sided differencing at the edges
if exist('type_original')
    coeff = fd_coefficient_matrix('one-sided',order);
    if accuracy>6; accuracy = 6; end
    % forward derivative for first few points
    direction = 1; 
    derivative(pra(1:length(pra)/2),:) = derivative_one_sided(var,pra(1:length(pra)/2),accuracy,order,d_dim,direction,coeff);
    
    % backward derivative for last few points
    direction = -1; 
    derivative(pra(length(pra)/2 + 1:end),:) = derivative_one_sided(var,pra(length(pra)/2 + 1:end),accuracy,order,d_dim,direction,coeff);
end
if dim == 2; derivative = derivative.'; end

%% function to calculate central differencing derivative
function [derivative] = derivative_central(var,lcns,accuracy,order,d_dim,coeff)
% var:          Two-dimensional variable
% lcns:         Locations along first dimension where derivative has to be
%               calculated
% accuracy:     Accuracy of finite difference formulation; 
%               2,4,6,8 for central difference schemes.
% order:        Order of derivative: 1 for first derivative (e.g. du/dx) and 2
%               for second order derivative (e.g. d2u/dx2)
% d_dim:        spacing along the first dimension
% coeff:        Coefficient matrix for finite difference formulation
derivative = zeros(length(lcns),size(var,2)); % initialize size of derivative
if order ==1 % for first order derivative
%  du/dx =  A(1,1)*( u(n+1,:) - u(n-1) )/dx % Second order accurate
%  du/dx =  A(2,1)*( u(n+1,:) - u(n-1) )/dx + A(2,2)*( u(n+2,:) - u(n-2) )/dx % Fourth order accurate
%  and so on...
    for term_cnt = 1:accuracy/2 %
        derivative = derivative + coeff(accuracy/2,term_cnt)*(var(lcns+term_cnt,:) - var(lcns-term_cnt,:))/d_dim;
    end
elseif order == 2
%  d2u/dx2 =  (A(1,2)*(u(n-1,:) + A(1,1)*(u(n,:) + A(1,2)*(u(n+1,:))/dx^2 % Second order accurate
   for term_cnt = -accuracy/2:accuracy/2
        derivative = derivative + coeff(accuracy/2,abs(term_cnt)+1)*(var(lcns+term_cnt,:))/d_dim^2;
    end
end

%% Calculate derivative for one sided difference
function [derivative] = derivative_one_sided(var,lcns,accuracy,order,d_dim,direction,coeff)
% var:          Two-dimensional variable
% lcns:         Locations along first dimension where derivative has to be
%               calculated
% accuracy:     Accuracy of finite difference formulation; 
%               2,4,6,8 for central difference schemes.
% order:        Order of derivative: 1 for first derivative (e.g. du/dx) and 2
%               for second order derivative (e.g. d2u/dx2)
% d_dim:        spacing along the first dimension
% direction:    For one-sided formulation, direction is given as 1 for
%               forward differencing, and -1 for backward differencing.
% coeff:        Coefficient matrix for finite difference formulation
derivative = zeros(length(lcns),size(var,2));
if order == 1 %% for first order derivative
%  du/dx =  ( A(1,1)*u(n,:) +A(1,2)*u(n+1) )/dx % Fist order accurate forward difference
%  du/dx =  (- A(1,1)*u(n,:) - A(1,2)*u(n-1) )/dx % Fist order accurate forward difference
% similarly,
%  du/dx =  ( A(2,1)*u(n,:) + A(2,2)*u(n+1)  + A(2,3)*u(n+2) )/dx % second order accurate forward difference
%  du/dx =  (- A(2,1)*u(n,:) - A(2,2)*u(n-1) - A(2,3)*u(n-2) )/dx % second order accurate backward difference
%  and so on...    
    for term_cnt = 1:accuracy+1
        derivative = derivative + coeff(accuracy,term_cnt)*direction*var(lcns+direction*(term_cnt-1),:)/d_dim;
    end
elseif order == 2
%  d2u/dx2 =  ( A(1,1)*u(n,:) +A(1,2)*u(n+1) + +A(1,3)*u(n+2)  )/dx^2 % Fist order accurate forward difference
%  d2u/dx2 =  ( - A(1,1)*u(n,:) - A(1,2)*u(n-1) - A(1,3)*u(n-2) )/dx^2 % Fist order accurate backward difference
    for term_cnt = 1:accuracy+2
        derivative = derivative + coeff(accuracy,term_cnt)*direction*var(lcns+direction*(term_cnt-1),:)/d_dim^2;
    end
end

%% Load Coefficient matrix for finite difference formulations:
function [fd_coeff] = fd_coefficient_matrix(type,order)
% Ref:      https://en.wikipedia.org/wiki/Finite_difference_coefficient
% type:     one-sided (backward or forward), central 
% order:    1 for first derivative e.g. du/dx and 2 for second order
%           derivative e.g. d2u/dx2
% Accuracy: For one sided derivatives 1st to 6th coefficent rows correspond 
%           to 1st to
%           6th order accurate formulations.
%           For central derivatives, 1st to 4th coefficient rows correspond
%           to 2nd to 8th order accurate formulations.  
if strcmp(type,'one-sided') && order == 1
fd_coeff = [-1      1       0       0       0       0       0;
            -3/2    2       -1/2    0       0       0       0;
            -11/6   3       -3/2    1/3     0       0       0;
            -25/12  4       -3      4/3     -1/4    0       0;
            -137/60 5       -5      10/3    -5/4    1/5     0;
            -49/20  6       -15/2   20/3    -15/4   6/5     -1/6];

elseif strcmp(type,'one-sided') && order == 2
fd_coeff = [1       -2          1       0       0       0           0           0;
            2       -5          4       -1      0       0           0           0;
            35/12   -26/3       19/2    -14/3   11/12   0           0           0;
            15/4    -77/6       107/6   -13     61/12   -5/6        0           0;
            203/45  -87/5       117/4   -254/9  33/2    -27/5       137/180     0;
            469/90  -223/13     879/20  -949/18 41      -210/10     1019/180    -7/10];

elseif     strcmp(type,'central') && order == 1
fd_coeff = [1/2     0       0       0;
            2/3     -1/12   0       0; 
            3/4     -3/20   1/60    0;
            4/5     -1/5    4/105   -1/280];
    
elseif     strcmp(type,'central') && order == 2
fd_coeff = [-2      1       0       0       0;
            -5/2    4/3     -1/12   0       0;
            -49/18  3/2     -3/20   1/90    0;
            -205/72 8/5     -1/5    8/315   -1/560];
end
 