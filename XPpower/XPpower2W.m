fn = 'XPpower2W';
folder = '/usr/brlcad/bin/';





delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');
%% chip body


H = [-10.16 -5.08 6.88, -10.16 5.08 6.88, 10.16 5.08 6.88, 10.16 -5.08 6.88];
H = [H, H + [0 0 -6.88, 0 0 -6.88, 0 0 -6.88, 0 0 -6.88]] * 0.393700;
fprintf(fid, 'in body1s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);



% Notch
fprintf(fid, 'in body1h.s rcc %g %g %g   %g %g %g   %g\n', [-9 -3.92 6.98, 0 0 -0.2, 0.5] * 0.393700);

%% Create the model
fprintf(fid, 'comb body.C u body1s.s - body1h.s\n');

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

