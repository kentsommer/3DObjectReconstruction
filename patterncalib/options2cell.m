function C = options2cell(C,varargin)
for i=1:2:length(varargin)-1
    if ischar(varargin{i})
        eval(sprintf('C.%s=%s;',lower(varargin{i}),lower(num2str(varargin{i+1}))));
    else return;
    end
%     sprintf('C.%s=%s',num2str(varargin{i}),num2str(varargin{i+1}))
end;
end