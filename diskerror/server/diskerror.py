from yapsy.IPlugin import IPlugin
from yapsy.PluginManager import PluginManager
from django.template import loader, Context
from django.db.models import Count
from server.models import *
from django.shortcuts import get_object_or_404
from datetime import datetime, timedelta
import server.utils as utils

class DiskError(IPlugin):
    def show_widget(self, page, machines=None, theid=None):
        # The data is data is pulled from the database and passed to a template.
        
        # There are three possible views we're going to be rendering to - front, bu_dashbaord and group_dashboard. If page is set to bu_dashboard, or group_dashboard, you will be passed a business_unit or machine_group id to use (mainly for linking to the right search).
        if page == 'front':
            t = loader.get_template('diskerror/templates/front.html')
            if not machines:
                machines = Machine.objects.all()
        
        if page == 'bu_dashboard':
            t = loader.get_template('diskerror/templates/id.html')
            if not machines:
                machines = utils.getBUmachines(theid)
        
        if page == 'group_dashboard':
            t = loader.get_template('diskerror/templates/id.html')
            if not machines:
                machine_group = get_object_or_404(MachineGroup, pk=theid)
                machines = Machine.objects.filter(machine_group=machine_group)
        
        if machines:
            time_28days = datetime.now() - timedelta(days=28)
            time_7days = datetime.now() - timedelta(days=7)
            warnings = machines.filter(historicalfact__fact_name='diskerror', historicalfact__fact_data__gte=1, historicalfact__fact_recorded__gte=time_28days).distinct().count()
            errors = machines.filter(historicalfact__fact_name='diskerror', historicalfact__fact_data__gte=1, historicalfact__fact_recorded__gte=time_7days).distinct().count()
        else:
            warnings = None
            errors = None
    
        c = Context({
            'title': 'Disk Errors',
            'warnings': warnings,
            'errors': errors,
            'page': page,
            'theid': theid
        })
        return t.render(c), 4
        
    def filter_machines(self, machines, data):
        if data == 'warnings':
            time_28days = datetime.now() - timedelta(days=28)
            machines = machines.filter(historicalfact__fact_name='diskerror', historicalfact__fact_data__gte=1, historicalfact__fact_recorded__gte=time_28days).distinct()
            title = 'Machines with recorded disk I/O errors in the past 28 days'
    
        elif data == 'errors':
            time_7days = datetime.now() - timedelta(days=7)
            machines = machines.filter(historicalfact__fact_name='diskerror', historicalfact__fact_data__gte=1, historicalfact__fact_recorded__gte=time_7days).distinct()
            title = 'Machines with recorded disk I/O errors in the past 7 days'
    
        else:
            machines = None
            title = 'Unknown'
    
        return machines, title
