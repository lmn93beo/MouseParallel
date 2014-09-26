function string = list2string(list, sep)
% Returns a string representation of the list
string = '';
for i = 1:numel(list)
        string = [string num2str(list(i)) sep];
end