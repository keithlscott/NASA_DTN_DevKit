#!/usr/bin/python

import getopt
import time
from threading import Timer
import sys
import os
import datetime
import wx
import wx.lib.scrolledpanel as scrolled

global labelWidth
global borderWidth
global nodeNames

nodeNames = {}
ignoreLinks = []

try:
	myDir = os.path.dirname(os.path.realpath(__file__))
	myDir = '.'
	print 'reading prefs from: %s' % (myDir+'/'+'cg2Prefs.py')
	execfile(myDir+'/'+'cg2Prefs.py')
except:
	pass

print "nodeNames:", nodeNames

firstContactTime = None
startTime = None

itemHeight=10
borderWidth=5
labelWidth=100
globalPct=0

def getContacts(fileName=None):
    global firstContact

    if fileName==None:
	print "Attempting to read contacts from running ion..."
	os.system('echo "l contact" | ionadmin | grep "From" | sed -e "s/: //" > contacts.txt')
	fileName = 'contacts.txt'
	os.system('touch foo')

    contacts = []
    if fileName==None:
        fileName = 'test1.txt'

    print "fileName is:", fileName
    f = open(fileName)
    while True:
        line = f.readline()
        if line == '':
            break
        contacts += [line]

    f.close()
    
    return contacts

class curTime:
	def __init__(self, contacts, baseTime=None, timeScale=1):
		self.contacts = contacts[:]
		self.timeScale = timeScale
		self.curTime = None
		self.startTime = None
		self.baseTime = baseTime
		self.timeScale = timeScale
		self.updateCurTime()

	def updateCurTime(self):
		if self.baseTime=='abs':
			self.curTime = datetime.datetime.utcnow()
		elif self.baseTime=='rel':
			if self.startTime==None:
				self.startTime = datetime.datetime.utcnow()
			self.curTime = firstContactStart(self.contacts) + \
				       self.timeScale*(datetime.datetime.utcnow()-self.startTime)
		else:
			print "BAD baseTime:", self.baseTime

		# print "updateCurTime:", self.curTime
		return self.curTime

	def getCurTime(self):
		return self.curTime

def contactStart(contact):
    res = dateTimeFromCGEntry((contact.split())[1])
    return res

def contactEnd(contact):
    res = dateTimeFromCGEntry((contact.split())[3])
    return res

def firstContactStart(contacts):
    res = None
    for c in contacts:
	if res==None or contactStart(c)<res:
	    res = contactStart(c)
    #res = contactStart(contacts[0])
    return res

def lastContactEnd(contacts):
    res = None
    for c in contacts:
	if res==None or contactEnd(c)>res:
	    res = contactEnd(c)
    #res = contactEnd(contacts[-1])
    return res

def totalTime(contacts):
    first = firstContactStart(contacts)
    last = lastContactEnd(contacts)
    delta = (last-first)
    # print delta
    # print delta.total_seconds()
    return delta.total_seconds()

def dateTimeFromCGEntry(cgEntry):
        res = cgEntry.replace('/', ' ')
        res = res.replace('-', ' ')
        res = res.replace(':', ' ')
        res = res.split()
        res = map(int, res)
        res = datetime.datetime(res[0], res[1], res[2],
                                res[3], res[4], res[5])
	return res

def dotFileFromIONContact(contacts, curTime, dotFileName):
    global nodeNames
    print "#### top of dotFileFromIONContact"
    f = open(dotFileName, 'w')
    f.write('graph contactGraph {\n')
    isOn = {}
    for line in contacts:
        tokens = line.split()
	start = dateTimeFromCGEntry(tokens[1])
	end   = dateTimeFromCGEntry(tokens[3])
        
	if (start<=curTime) and (curTime<=end):
	    if not (tokens[9], tokens[12]) in isOn:
	    	isOn[(tokens[9], tokens[12])] = False
	    isOn[(tokens[9], tokens[12])] = True
	else:
	    if not (tokens[9], tokens[12]) in isOn:
	        isOn[(tokens[9], tokens[12])] = False
            
    for l in isOn:
	src=int(l[0])
	dst=int(l[1])
	if [src,dst] in ignoreLinks:
		print "$$$ Ignoring link (%d, %d) $$$" % (src, dst)
		continue

	if l[0] in nodeNames:
		n1 = nodeNames[l[0]]
	else:
		n1 = l[0]
	if l[1] in nodeNames:
		n2 = nodeNames[l[1]]
	else:
		n2 = l[1]

	# If reverse link is also here and both same state, only show once
	if (l[1],l[0]) in isOn.keys():
		if int(dst)>int(src):
			continue
	
	f.write('    "%s" -- "%s"' % (n1, n2))

	if not isOn[l]:
	    f.write(' [color="0.2 0.05 0.8"]')
	else:
	    f.write(' [color=red]')
	f.write(';\n')

    f.write('}\n')
    f.close()
    print "#### Bottom of dotFileFromIONContact"

def startDotGraph(contacts):
    # Generate initial dot file from contact graph
    curTime = firstContactStart(contacts)
    dotFileFromIONContact(contacts, curTime, 'contactGraph.dot')

    print "yip"
    # Start dot watching the contactGraph.dot file
    os.system('dot -Txlib contactGraph.dot &')
    time.sleep(1)

    # Kick off the
    updateDotGraph()

def updateDotGraph():
	global theTimer
	curTime = theTimer.updateCurTime()

	print "Doing updateDotGraph; curTime is:", curTime, "baseTime is", baseTime

        dotFileFromIONContact(contacts, curTime, 'contactGraph.dot')
	Timer(1, updateDotGraph, ()).start()

class myPanel(wx.Panel):
    def __init__(self, *args, **kwargs):
	wx.Panel.__init__(self, *args, **kwargs)
	self.label = None
	self.src = None
	self.dst = None
	self.extents = []	# In (%,%)
	self.SetBackgroundColour('white')
        self.Bind(wx.EVT_PAINT, self.onPaint, self)
        self.Bind(wx.EVT_MOTION, self.onMotion)
        self.Bind(wx.EVT_ENTER_WINDOW, self.onMouseEnters)
        self.Bind(wx.EVT_LEAVE_WINDOW, self.onMouseLeaves)
	# self.SetSize((labelWidth, itemHeight))

    def onMouseEnters(self, event):
	pass

    def onMouseLeaves(self, event):
	pass

    def onMotion(self, event):
	pass

    def getExtents(self):
	return self.extents

    def addExtent(self, start, end, src=None, dst=None):
	#global ignoreLinks
	global nodeNames
	#print "Adding extent", (start, end), "to panel",
	#print "  src=%s dst=%s" % (src, dst),
	#print "nodeNames:", nodeNames,
	#print ""
	#print "ignoreLinks=%s" % (ignoreLinks)
	if [int(src),int(dst)] in ignoreLinks:
		print "$$$$$ Ignoring link $$$$$"
		return

	if src in nodeNames:
		self.src = nodeNames[src]
	else:
		self.src = src
	if dst in nodeNames:
		self.dst = nodeNames[dst]
	else:
		self.dst = dst
	self.extents += [(start, end)]
	# print " now", len(self.extents)

    def onPaint(self, event):
	global itemHeight
	global globalPct

	self.SetBackgroundColour('white')
	dc = wx.PaintDC(self)
	dc.DestroyClippingRegion()
	dc.SetClippingRegion(0,0,10000,10000)
	dc.Clear()
	if self.label!=None:
	    dc.DrawText(self.label, 0, 0)
	if len(self.extents)==0:
		return

	size = self.GetSize()[0]
	height = self.GetSize()[1]

	dc.SetPen(wx.Pen('black', 1))
	last = 0
	for e in self.extents:
		# print "Drawing contact", self.src, self.dst, ":", (e[0], e[1]), "globalPct:", globalPct
		#dc.DrawLine(e[0]*size, 10, e[1]*size, 10)
		#dc.SetBrush(wx.WHITE_BRUSH)
		#dc.DrawRectangle(last, 0,
		#		e[0]*size, height)

		if globalPct==None:
			beBlue = True
		elif (e[0]>globalPct) or (e[1]<globalPct):
			beBlue = True
		else:
			beBlue = False

		if beBlue:
			dc.SetBrush(wx.BLUE_BRUSH)
		else:
			dc.SetBrush(wx.RED_BRUSH)

		dc.DrawRectangle(e[0]*size, 0,
				(e[1]-e[0])*size, height)
		last = e[1]*size
	
	#dc.SetBrush(wx.WHITE_BRUSH)
	# dc.DrawRectangle(last-1, 0,
	# 		size, height)

	dc.EndDrawing()

class froggerFrame(wx.Frame):
	
    def findEntry(self, rows, src, dst):
	for r in rows:
	    if r['src']==src and r['dst']==dst:
		return r
	return None

    def go(self):
	global labelWidth
	rows = []

	self.totalTime = (self.lastContactEnd-self.firstContactStart).total_seconds()

	for c in self.contacts:
	    src = c.split()[9]
	    dst = c.split()[12]
	    start = contactStart(c)
	    end = contactEnd(c)

	    if ([int(src), int(dst)] in ignoreLinks):
		continue

	    row = self.findEntry(rows, src, dst)
	    if row == None:
		# Make new row
		row = {}
		row['panel'] = myPanel(self)
		row['src'] = src
		row['dst'] = dst
		row['firstContactStart'] = self.firstContactStart
		row['lastContactEnd'] = self.lastContactEnd
		rows += [row]

	    # Add contact
            if (end-self.firstContactStart).total_seconds()/self.totalTime > 1:
		# print "XXX ODD ", (end-self.firstContactStart).total_seconds(), self.totalTime
		# print "XXX END ", end
		# print "XXX LAST", self.lastContactEnd
		pass
	    
	    row['panel'].addExtent((start-self.firstContactStart).total_seconds()/self.totalTime,
                                   (end-self.firstContactStart).total_seconds()/self.totalTime,
				   src, dst)

	return rows

    def __init__(self, parent, title, theTimer, contacts=None, baseTime=None):
	global borderWidth

	self.startTime = None
	self.parent = parent
	self.theTimer = theTimer
	self.contacts = contacts
	self.firstContactStart = firstContactStart(contacts)
	self.lastContactEnd = lastContactEnd(contacts)
	self.baseTime = baseTime
	self.totalTime = totalTime(self.contacts)

	self.maxContactTime = 3600
	tmp = self.firstContactStart + datetime.timedelta(seconds=self.maxContactTime)
	if tmp < self.lastContactEnd:
		self.lastContactEnd = tmp

	global labelWidth, itemHeight

        wx.Frame.__init__(self, parent, title=title, size=(-1,-1))
	wx.Frame.CreateStatusBar(self, 1, style=wx.FULL_REPAINT_ON_RESIZE, name="statusBar")
        self.Bind(wx.EVT_MOTION, self.onMotion)

	self.SetMinSize((500,500))
	self.SetMaxSize((1200,1200))

	# Holds 2 other sizers side-by side
	# labels | timelines
 	self.sizerH = wx.BoxSizer(wx.HORIZONTAL)

	rows = self.go()

	# Labels
 	self.sizerV1 = wx.BoxSizer(wx.VERTICAL)
	self.sizerH.Add(self.sizerV1, proportion=0, flag=wx.EXPAND)
	for r in rows:
	    if [int(r['src']),int(r['dst'])] in ignoreLinks:
		continue
            # panel = myPanel(self)
	    label = ""
	    if r['src'] in nodeNames:
		label += nodeNames[r['src']]
	    else:
		label += r['src']
	    label += " -- "
	    if r['dst'] in nodeNames:
		label += nodeNames[r['dst']]
	    else:
		label += r['dst']

	    panel = wx.StaticText(self, pos=(labelWidth, itemHeight), label=label)
	    panel.Wrap(labelWidth)
	    #panel.SetSize((labelWidth, itemHeight))

	    self.sizerV1.Add(panel, proportion=1, flag=wx.EXPAND | wx.ALL, border=borderWidth)

	# Timelines
	#self.timelinesPanel = scrolled.ScrolledPanel(self)
	#self.timelinesPanel.SetBackgroundColour('yellow')
	##desc = wx.StaticText(self.timelinesPanel, 01, ("foo "*50+"\n")*40)

 	self.sizerV2 = wx.BoxSizer(wx.VERTICAL)
	for r in rows:
	    self.sizerV2.Add(r['panel'], proportion=1, flag=wx.EXPAND | wx.ALL, border=borderWidth)
	    # print "Adding panel with ", len(r['panel'].getExtents()), "extents."

	# self.foo.Add(self.sizerV2, 1, wx.EXPAND)
	# self.timelinesPanel.SetSizer(foo)
	# self.timelinesPanel.SetupScrolling()
	self.sizerH.Add(self.sizerV2, proportion=1, flag=wx.EXPAND | wx.ALL)

	self.SetSizer(self.sizerH)
	self.SetAutoLayout(1)

	self.Bind(wx.EVT_PAINT, self.OnPaint)

	self.timer = wx.Timer(self, 100)
	self.timer.Start(500, oneShot=False)
	# self.Bind(wx.EVT_TIMER, self.updateCurTime)
	self.Bind(wx.EVT_TIMER, self.updateStatusBar)

        self.Show(True)
	self.theTimer.updateCurTime()

    def onMotion(self, event = None):
	pass

    def updateStatusBar(self, event=None):
	global globalPct
	global labelWidth, borderWidth

	statusText = self.theTimer.getCurTime().ctime() + "  --  "
	statusText += ("start: " + self.firstContactStart.ctime())
	statusText += ("  --  end: "+self.lastContactEnd.ctime())

	self.Refresh(eraseBackground=False, rect=(0,0,2000,2000))
	globalPct = (self.theTimer.updateCurTime()-self.firstContactStart).total_seconds()/self.totalTime

	foo = wx.GetMousePosition()
	bar = self.ScreenToClient(foo)

	if ( (bar[0]>(labelWidth+2*borderWidth)) and (bar[1]>0) and
             (bar[0]<(self.GetSize()[0])) and (bar[1]<self.GetSize()[1])):
		temp = (float(bar[0])/self.GetSize()[0])*self.totalTime
		bar = datetime.timedelta(seconds=temp)
		foo = self.firstContactStart + bar
		statusText += ("  --  mouse: "+foo.ctime())

	self.SetStatusText(statusText)

    def OnPaint(self, event=None):
	global labelWidth

	curTime = self.theTimer.getCurTime()

	theSize = self.sizerV2.GetSize()
	thePos = self.sizerV2.GetPosition()
	pctDone = float((self.theTimer.getCurTime()-self.firstContactStart).total_seconds()) / self.totalTime
	pctDone = globalPct
	if pctDone<1:
	    xOffset = thePos[0] + 5 + (pctDone * (theSize[0]-10))
	    dc = wx.PaintDC(self)
	    dc.SetPen(wx.Pen('red', 2))
	    dc.DrawLine(xOffset,0, xOffset, theSize[1])

class wxFroggerApp(wx.App):
    def OnInit(self):
        return True

    def setContacts(self, contacts, theTimer):
        frame = froggerFrame(None, title="CGRFrogger", theTimer=theTimer, baseTime='firstContact', contacts=contacts)
        frame.Show(True)

def usage():
    print "%s OPTIONS [-f contactsFile]" % sys.argv[0]
    print "Options are:"
    print "    -h	        Print help."
    print "    -b [rel|abs]     Set epoch as relative to start of program or absolute time."
    print "    -t timeScale     Set time scaling factor (run faster or slower than real-time)."
    print "Notes:"
    print "    Format of contactsFile is as output from ionadmin 'l contact' cmd"
    sys.exit(0)

if __name__=="__main__":
    baseTime = 'abs'
    timeScale = 1

    try:
	execfile('cg2Prefs.py')
    except:
	pass

    try:
	opts, args = getopt.getopt(sys.argv[1:], "b:hf:t:",
				   ["help", "file=", "timescale="])
    except getopt.GetoptError, err:
	print str(err)
	sys.exit(2)

    fileName = None
    for o, a in opts:
	if o in ("-h", "--help"):
	    usage()
	    sys.exit(0)
	elif o in ("-b"):
	    if a in ("rel", "abs"):
		baseTime = a
	    else:
		print "baseTime needs to be 'rel' or 'abs'"
	elif o in ("-f", "--file"):
	    fileName = str(a)
	elif o in ("-t", "--timescale"):
	    timeScale=int(a)
	else:
	    assert False, "unhandled option"

    #contacts = getContacts('test2.txt')
    contacts = getContacts(fileName)
    print "Contacts read:"
    for c in contacts:
        print c,
    
    theTimer = curTime(contacts, baseTime, timeScale)

    startDotGraph(contacts)

    foo = wxFroggerApp()
    foo.setContacts(contacts, theTimer)
    foo.MainLoop()
