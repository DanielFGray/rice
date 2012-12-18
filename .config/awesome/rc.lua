require('awful')
require('awful.autofocus')
require('awful.rules')
require('beautiful')
require('naughty')
require('vicious')
require('shifty')
local freedesktop_utils = require("freedesktop.utils")
local freedesktop_menu = require("freedesktop.menu")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.add_signal('debug::error', function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = 'Oops, an error happened!',
            text = err
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
modkey            = 'Mod4'
configdir         = awful.util.getdir('config')..'/'
homedir           = os.getenv('HOME')
exec              = awful.util.spawn
terminal          = 'urxvtc '
term_cmd          = terminal..'-e '
editor            = 'gvim '
browser           = 'luakit'
filemanager       = 'dolphin'
mpdclient         = term_cmd..'ncmpcpp'
wirelessinterface = 'wlan0'
wiredinterface    = 'eth0'
beautifultheme    = configdir..'themes/dfg/'

function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    awful.util.spawn_with_shell('pgrep -u $USER -x '..findme..' > /dev/null || ('..cmd..')')
 end

exec     ('xrdb -load '..homedir..'/.Xresources')
exec     ('synclient TapButton1=1')
run_once ('urxvtd')
run_once (homedir..'/bin/compton')
run_once ('mpd')
--run_once ('thunar --daemon')
run_once ('xscreensaver -no-splash')
--run_once ('xfce4-power-manager')
run_once ('clipit')
run_once ('nm-applet')
run_once ('volti')

beautiful.init(beautifultheme..'theme.lua')

layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

use_titlebar = true

shifty.config.tags = {
    web = {
        layout    = awful.layout.suit.max,
        exclusive = false,
        position  = 1,
    --    init      = true,
        screen    = 1,
        slave     = true,
        spawn     = browser,
    },
    --mail = {
    --    layout    = awful.layout.suit.tile,
    --    exclusive = false,
    --    position  = 5,
    --    spawn     = mail,
    --    slave     = true
    --},
    --media = {
    --    layout    = awful.layout.suit.float,
    --    exclusive = false,
    --    position  = 8,
    --},
    --office = {
    --    layout   = awful.layout.suit.tile,
    --    position = 9,
    --},
}

shifty.config.apps = {
    {
        match = {
            'gmrun',
            'xfrun4',
        },
	--slave = true,
        float = true,
    },
    {
        match = {
            'Vimperator',
            'Firefox',
            'luakit',
            'Nightly',
	    'uzbl',
        },
        tag = 'web',
    },
    {
        match = {
            'Shredder.*',
            'Thunderbird',
            'mutt',
        },
        tag = 'mail',
    },
    {
        match = {
            'pcmanfm',
            'thunar',
            'nautilus',
        },
        slave = true
    },
    {
        match = {
            'OpenOffice.*',
            'Abiword',
            'Gnumeric',
        },
        tag = 'office',
    },
    {
        match = {
            'Mplayer.*',
            'Mirage',
            'qiv',
            'gimp',
            'gtkpod',
            'Ufraw',
            'easytag',
        },
        tag = 'media',
    },
    {
        match = {
            'MPlayer',
            'Gnuplot',
            'galculator',
        },
        float = true,
    },
    {
        match = {
            terminal,
        },
        slave = true,
    },
    {
        match = {''},
        honorsizehints = false,
        buttons = awful.util.table.join(
            awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
            awful.button({ modkey }, 1, function(c)
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end),
            awful.button({ modkey }, 3, awful.mouse.client.resize)
        )
    },
}

shifty.config.defaults = {
    layout = awful.layout.suit.floating,
    ncol = 1,
    mwfact = 0.50,
    floatBars = true,
    guess_name = true,
    guess_position = true,
}
-- }}}

-- {{{ Menu
mnuAwesome = {
    { 'edit configs', editor..configdir..'rc.lua '..beautifultheme..'theme.lua' },
    { 'restart',      awesome.restart },
    { 'quit',         awesome.quit }
}

mnuPower = {
    { 'suspend',   'dbus-send --system --print-reply --dest="org.freedesktop.UPower"     /org/freedesktop/UPower org.freedesktop.UPower.Suspend' },
    { 'hibernate', 'dbus-send --system --print-reply --dest="org.freedesktop.UPower"     /org/freedesktop/UPower org.freedesktop.UPower.Hibernate' },
    { 'reboot',    'dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart' },
    { 'halt',      'dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop' }
}

mnuCompositing = {
    { 'stop',  'pkill compton' },
    { 'start', 'compton' },
}

mnuApps = {}
for _, item in ipairs(freedesktop_menu.new()) do table.insert(mnuApps, item) end

mnuMain = awful.menu({ items = {
    { 'terminal',     terminal } ,
    { 'tmux',         term_cmd..'tmux' } ,
    { 'editor',       editor },
    { 'browser',      browser },
    { 'file manager', filemanager },
    { 'mpd client',   mpclient },
    { 'luakit',       'luakit' },
    { 'htop',         term_cmd..'htop' },
    { 'weechat',      term_cmd..'weechat-curses' },
    { 'rtorrent',     term_cmd..'rtorrent' },
    { 'gimp',         'gimp' },
    { 'composite',    mnuCompositing },
    { 'apps',         mnuApps},   
    { 'awesome',      mnuAwesome },
    { 'power',        mnuPower  }
}})


mylauncher = awful.widget.launcher({
    image = image(beautiful.awesome_icon),
    menu = mnuMain
})
-- }}}

--  {{{ Wibox
datewidget = widget({ type = 'textbox' })
vicious.register(datewidget, vicious.widgets.date, ' %a %b %d %Y  %l:%M:%S ', 1)
datewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec('gsimplecal') end)
))

mysystray = widget({ type = 'systray', align = 'left' })

mywibox = { }
mypromptbox = { }
mylayoutbox = { }
mytaglist = { }
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1,        awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3,        function(tag) tag.selected = not tag.selected end),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4,        awful.tag.viewnext),
    awful.button({ }, 5,        awful.tag.viewprev)
)

mytasklist = { }
mytasklist.buttons = awful.util.table.join( awful.button({ }, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
        client.focus = c
        c:raise()
    end
end))

spacer       = widget({ type = 'textbox'  })
spacer.text  = ' <span color="'..theme.bg_focus..'">|</span> '

mpdicon = widget({ type = 'imagebox', align = 'left' })
mpdicon.image = image(beautifultheme..'icons/music.png')
mpdwidget = widget({ type = 'textbox' })
vicious.register(mpdwidget, vicious.widgets.mpd, function(widget, args)
    if args['{state}'] == ('Stop' or 'N/A') then 
        mpdicon.visible = false
        return ''
    else 
        mpdicon.visible = true
        if args['{state}'] == 'Pause' then
            return ' <span color="'..theme.colors.base0..'">'..args['{Artist}']..' - '..args['{Title}']..'</span>'..spacer.text
        else
            return ' '..args['{Artist}']..'<span color="'..theme.colors.base0..'"> - </span>'..args['{Title}']..spacer.text
        end
    end
end, 5)

mpdwidget:buttons( awful.util.table.join(
    awful.button({ }, 1, function() exec(mpdclient) end),
    awful.button({ }, 3, function() exec('mpc toggle', false) end),
    awful.button({ }, 4, function() exec('mpc prev', false) end),
    awful.button({ }, 5, function() exec('mpc next', false) end)
))

cpuicon = widget({ type = 'imagebox', align = 'left' })
cpuicon.image = image(beautifultheme..'icons/cpu.png')
cpuwidget = widget({ type = 'textbox' })
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args) return string.format('%02d', args[1])..'% ' end, .5)

memicon = widget({ type = 'imagebox', align = 'left' })
memicon.image = image(beautifultheme..'icons/mem.png')
memwidget = widget({ type = 'textbox' })
vicious.register(memwidget, vicious.widgets.mem,
    '$1% <span color="'..theme.colors.base0..'">(</span>$2<span color="'..theme.colors.base0..'">/$3)</span> ', 5)

baticon = widget({ type = 'imagebox' })
baticon.image = image(beautifultheme..'icons/bat.png')
batwidget = widget({ type = 'textbox' })
vicious.register(batwidget, vicious.widgets.bat, '$1$2% ', 30, 'BAT1')

sensicon = widget({ type = 'imagebox', align = 'left' })
sensicon.image = image(beautifultheme..'icons/temp.png')
senswidget = widget({ type = 'textbox' })
vicious.register(senswidget, vicious.widgets.thermal, function(widget, args)
    local temp = tonumber(string.format('%.0f', args[1] * 1.8 + 32))
    if temp > 190 then
        naughty.notify({
           title = 'Temperature Warning',
           text = 'Is it me or is it hot in here?',
           fg = beautiful.fg_urgent,
           bg = beautiful.bg_urgent
        })
        temp = '<span color="'..theme.colors.red..'">'..temp..'</span>'
    end
    return temp ..'<span color="'..theme.colors.base0..'">°F</span> '
end, 15, 'thermal_zone0')

wifiicon = widget({ type = 'imagebox', align = 'left' })
wifiicon.image = image(beautifultheme..'icons/wifi.png')
wifiwidget = widget({ type = 'textbox' })
vicious.register(wifiwidget, vicious.widgets.wifi, function(widget, args)
    if args['{link}'] == 0 then
        wifiicon.visible = false
        return ''
    else
        wifiicon.visible = true
        return string.format('%i%% ', args['{link}'] / 70 * 100)
    end
end, 4, wirelessinterface)

netdownicon = widget({ type = 'imagebox', align = 'left' })
netdownicon.image = image(beautifultheme..'icons/down.png')
netdownwidget = widget({ type = 'textbox' })
vicious.register(netdownwidget, vicious.widgets.net, function(widget, args)
    local interface = ''
    if args['{'..wirelessinterface..' carrier}'] == 1 then
        interface = wirelessinterface
    elseif args['{'..wiredinterface..' carrier}'] == 1 then
        interface = wiredinterface
    else
        netdownicon.visible = false
    	return 'disconnected'
    end
    netdownicon.visible = true
    return args['{'..interface..' down_kb}']..'k<span color="'..theme.colors.base0..'">/'..args['{'..interface..' rx_mb}']..'M</span> '
end, 3)

netupicon = widget({ type = 'imagebox', align = 'left' })
netupicon.image = image(beautifultheme..'icons/up.png')
netupwidget = widget({ type = 'textbox' })
vicious.register(netupwidget, vicious.widgets.net, function(widget, args)
    local interface = ''
    if args['{'..wirelessinterface..' carrier}'] == 1 then
        interface = wirelessinterface
    elseif args['{'..wiredinterface..' carrier}'] == 1 then
        interface = wiredinterface
    else
        netupicon.visible = false
        return ''
    end
    netdownicon.visible = true
    return args['{'..interface..' up_kb}']..'k<span color="'..theme.colors.base0..'">/'..args['{'..interface..' tx_mb}']..'M</span>'
end, 3)

for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist( function(c)
        return awful.widget.tasklist.label.currenttags(c, s)
    end, mytasklist.buttons)
    mywibox[s] = { }
    mywibox[s][1] = awful.wibox({ position = 'top',    screen = s, height = 12 })
    mywibox[s][2] = awful.wibox({ position = 'bottom', screen = s, height = 12 })
    mywibox[s][1].widgets = {
        mylayoutbox[s], 
        mytaglist[s], 
        mypromptbox[s], {
            cpuwidget, cpuicon,
            memwidget, memicon,
            --batwidget, baticon,
            senswidget, sensicon,
            spacer,
            netupwidget, netupicon,
            netdownwidget, netdownicon,
            wifiwidget, wifiicon,
            mpdwidget, mpdicon,
            layout = awful.widget.layout.horizontal.rightleft
        },
        layout = awful.widget.layout.horizontal.leftright
   }
   mywibox[s][2].widgets = {
        datewidget,
        s == 1 and mysystray or nil, {
            mylauncher,
            mytasklist[s],
            layout = awful.widget.layout.horizontal.flex
        },
        layout = awful.widget.layout.horizontal.rightleft
   }
end

shifty.taglist = mytaglist
shifty.init()
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function() mnuMain:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, 'h',                  awful.tag.viewprev),
    awful.key({ modkey }, 'l',                  awful.tag.viewnext),
    awful.key({ modkey }, 'Escape',             awful.tag.history.restore),
    awful.key({ modkey, 'Shift' }, 'd',         shifty.del),
    awful.key({ modkey, 'Control' }, 'h',       shifty.send_prev),
    awful.key({ modkey, 'Control' }, 'l',       shifty.send_next),
    awful.key({ modkey, 'Control' }, 'n',       function()
                                                    local t = awful.tag.selected()
                                                    local s = awful.util.cycle(screen.count(), t.screen + 1)
                                                    awful.tag.history.restore()
                                                    t = shifty.tagtoscr(s, t)
                                                    awful.tag.viewonly(t)
                                                end),
    awful.key({ modkey }, 'a',                  shifty.add),
    awful.key({ modkey }, 'r',                  shifty.rename),
    awful.key({ modkey, 'Shift'}, 'a',          function() shifty.add({nopopup = true}) end),
    awful.key({ modkey }, 'j',                  function()
                                                    awful.client.focus.byidx(1)
                                                    if client.focus then client.focus:raise() end
                                                end),
    awful.key({ modkey }, 'k',                  function()
                                                    awful.client.focus.byidx(-1)
                                                    if client.focus then client.focus:raise() end
                                                end),
    awful.key({ modkey }, 'w',                  function() mnuMain:toggle({keygrabber = true}) end),
    awful.key({ modkey }, 'Up',                 function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey }, 'Down',               function() awful.client.swap.byidx(1) end),
    --awful.key({ modkey, 'Shift' }, 'j',         function() awful.screen.focus(1) end),
    --awful.key({ modkey, 'Shift' }, 'k',         function() awful.screen.focus(-1) end),
    awful.key({ modkey }, 'u',                  awful.client.urgent.jumpto),
    awful.key({ modkey, 'Control' }, 'r',       awesome.restart),
    awful.key({ modkey, 'Shift' }, 'q',         awesome.quit),
    awful.key({ modkey }, 'Tab',                function() clientmenu = awful.menu.clients({ width=250},{keygrabber = true }) end),
    awful.key({ modkey }, 'Left',               function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey }, 'Right',              function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, 'Control' }, 'Left',    function() awful.tag.incnmaster(1) end),
    awful.key({ modkey, 'Control' }, 'Right',   function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, 'Control' }, 'Up',      function() awful.tag.incncol(1) end),
    awful.key({ modkey, 'Control' }, 'Down',    function() awful.tag.incncol(-1) end),
    awful.key({ modkey }, 'space',              function() awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, 'Shift' }, 'space',     function() awful.layout.inc(layouts, -1) end),
    awful.key({ }, 'XF86AudioRaiseVolume',      function() exec('amixer -q set Master 5%+') end),
    awful.key({ }, 'XF86AudioLowerVolume',      function() exec('amixer -q set Master 5%-') end),
    awful.key({ }, 'XF86AudioMute',             function() exec('amixer -q set Master toggle') end),
    awful.key({ }, 'XF86AudioPlay',             function() exec('mpc -q toggle', false) end),
    awful.key({ }, 'XF86AudioStop',             function() exec('mpc -q stop', false) end),
    awful.key({ }, 'XF86AudioNext',             function() exec('mpc -q next', false) end),
    awful.key({ }, 'XF86AudioPrev',             function() exec('mpc -q prev', false) end),
    awful.key({ modkey }, 'F1',                 function()
                                                    --local f_reader = io.popen( 'dmenu_path | dmenu -b -nb "'..beautiful.bg_normal..'" -nf "'..beautiful.fg_normal..'" -sb "'..beautiful.colors.blue..'" -sf "'.. beautiful.bg_normal ..'"')
                                                    awful.util.spawn_with_shell('dmenu_run -b -hist "'..homedir..'/.dmenu.history" -fn "UbuntuMono-8:normal"')
                                                    --exec('spring')
                                                end),
    awful.key({ modkey }, 'F2',                 function() exec('gmrun') end),
    awful.key({ modkey }, 'F3',			function()
    						    awful.prompt.run({ prompt = ' Web: ' },
						    mypromptbox[mouse.screen].widget,
    						    function(command)
    						        exec('firefox "http://yubnub.org/parser/parse?command='..command..'"')
    						        awful.tag.viewonly(tags[scount][3])
    						    end, nil,
                                                    awful.util.getdir('cache')..'/yubnub_eval')
    						end),
    awful.key({ modkey }, 'F4',                 function()
                                                    awful.prompt.run({prompt = ' Run Lua code: '},
                                                    mypromptbox[mouse.screen].widget,
                                                    awful.util.eval, nil,
                                                    awful.util.getdir('cache')..'/history_eval')
                                                end),
    awful.key({ modkey }, 'Return',             function() exec(terminal) end),
    awful.key({ modkey, 'Mod1' }, 'e',          function() exec(editor) end),
    awful.key({ modkey, 'Mod1' }, 'f',          function() exec(filemanager) end),
    awful.key({ modkey, 'Mod1' }, 'h',          function() exec(term_cmd..'htop') end),
    awful.key({ modkey, 'Mod1' }, 'l',          function() exec('xscreensaver-command --lock') end),
    awful.key({ modkey, 'Mod1' }, 'm',          function() exec(mpdclient) end),
    awful.key({ modkey, 'Mod1' }, 'v',          function() exec('pavucontrol') end),
    awful.key({ modkey, 'Mod1' }, 'w',          function() exec(browser) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey }, 'f',                  function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, 'x',                  function(c) c:kill() end),
    awful.key({ modkey, 'Control' }, 'space',   awful.client.floating.toggle),
    awful.key({ modkey, 'Control' }, 'Return',  function(c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey }, 'o',                  awful.client.movetoscreen),
    awful.key({ modkey, 'Shift' }, 'r',         function(c) c:redraw() end),
    awful.key({ modkey }, 't',                  awful.client.togglemarked),
    awful.key({ modkey }, 'm',                  function(c)
                                                    c.maximized_horizontal = not c.maximized_horizontal
                                                    c.maximized_vertical   = not c.maximized_vertical
                                                end)
)

shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

for i = 1, (shifty.config.maxtags or 9) do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i, function()
            local t =  awful.tag.viewonly(shifty.getpos(i))
        end),
        awful.key({modkey, 'Control'}, i, function()
            local t = shifty.getpos(i)
            t.selected = not t.selected
        end),
        awful.key({modkey, 'Control', 'Shift'}, i, function()
            if client.focus then
                awful.client.toggletag(shifty.getpos(i))
            end
        end),
        awful.key({modkey, 'Shift'}, i, function()
            if client.focus then
                t = shifty.getpos(i)
                awful.client.movetotag(t)
                awful.tag.viewonly(t)
            end
        end))
    end

root.keys(globalkeys)
--}}}

-- {{{ Signals
client.add_signal('focus', function(c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end 
    c.opacity = 1
end)

client.add_signal('unfocus', function(c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end 
    c.opacity = 0.9
end)

client.add_signal('manage', function (c, startup)
    --if awful.client.floating.get(c)
    --or awful.layout.get(c.screen) == awful.layout.suit.floating then
    --    if   c.titlebar then awful.titlebar.remove(c)
    --    else awful.titlebar.add(c, {modkey = modkey, height = '12', position = 'bottom'}) end
    --end
    c:add_signal('mouse::enter', function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    if not startup then
        awful.client.setslave(c)
        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
--}}}
