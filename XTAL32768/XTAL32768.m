fn = 'XTAL32768';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');


%% chip body

H = [-4.35 -1.8 1.25, -4.35 1.8 1.25, 4.35 1.8 1.25, 4.35 -1.8 1.25];
H = [H, H + [0.1 0.1 -1.25, 0.1 -0.1 -1.25, -0.1 -0.1 -1.25, -0.1 0.1 -1.25]] * 0.393700;
fprintf(fid, 'in body1s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [-4.35 -1.8 1.25, -4.35 1.8 1.25, 4.35 1.8 1.25, 4.35 -1.8 1.25];
H = [H, H + [1 0.1 1.25, 1 -0.1 1.25, -0.1 -0.1 1.25, -0.1 0.1 1.25]] * 0.393700;
fprintf(fid, 'in body2s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);


% join regions
fprintf(fid, 'r bodys.r');
for i = 1 : 2
    fprintf(fid, ' u body%ds.s', i);
end
fprintf(fid, '\n');

%% Create the model
fprintf(fid, 'comb body.C u bodys.r\n');

fprintf(fid, 'mater body.C "plastic" 153 255 127 0\n');

%% Create servo
fprintf(fid, 'comb %s.c u body.C\n', fn);
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
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g %s.c', folder, fn, fn, fn));

unix(sprintf('../meshconv -c stl %s1.stl -o %s', fn, fn));

%unix(sprintf('rm %s1.stl', fn));

