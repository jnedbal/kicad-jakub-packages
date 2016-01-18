fn = 'piezo';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');


%% piezo body
fprintf(fid, 'in body1s.s rcc 0 0 0   0 0 %g   %g\n', [6.9 6.3] * 0.393700);

%% piezo hole
fprintf(fid, 'in body1h.s rcc 0 0 %g   0 0 %g   %g\n', [2 6.9 1] * 0.393700);


%% Create the model
fprintf(fid, 'comb piezo.c u body1s.s - body1h.s\n');

fprintf(fid, 'mater piezo.c "plastic" 0 0 0 0\n');

fclose(fid);


%% Render the wheel
unix(sprintf('%smged -c %s.g < %s.mged', folder, fn, fn));

for i = 15 : 15 : 360
    unix(sprintf('%srt -a -90 -e %g -w 200 -n 200 -C255/255/255 -o %s%03g.png %s.g arduino.c', folder, i, fn, i, fn));
end

unix(sprintf('convert -delay 20 -loop 0 %s???.png %s.gif', fn, fn));

unix(sprintf('chmod 644 %s???.png', fn));
unix(sprintf('rm %s???.png', fn));

%% Create and fix an STL file
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g piezo.c', folder, fn, fn));

unix(sprintf('../meshconv -c stl piezo1.stl -o piezo'));

%unix(sprintf('rm %s1.stl', fn));

