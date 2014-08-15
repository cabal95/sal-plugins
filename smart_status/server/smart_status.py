from yapsy.IPlugin import IPlugin
from yapsy.PluginManager import PluginManager
from django.template import loader, Context
from django.db.models import Count
from server.models import *
from django.shortcuts import get_object_or_404
from datetime import datetime, timedelta
import server.utils as utils

class SmartStatus(IPlugin):
    def show_widget(self, page, machines=None, theid=None):
        # The data is data is pulled from the database and passed to a template.
        
        # There are three possible views we're going to be rendering to - front, bu_dashbaord and group_dashboard. If page is set to bu_dashboard, or group_dashboard, you will be passed a business_unit or machine_group id to use (mainly for linking to the right search).
        if page == 'front':
            t = loader.get_template('smart_status/templates/front.html')
            if not machines:
                machines = Machine.objects.all()
        
        if page == 'bu_dashboard':
            t = loader.get_template('smart_status/templates/id.html')
            if not machines:
                machines = utils.getBUmachines(theid)
        
        if page == 'group_dashboard':
            t = loader.get_template('smart_status/templates/id.html')
            if not machines:
                machine_group = get_object_or_404(MachineGroup, pk=theid)
                machines = Machine.objects.filter(machine_group=machine_group)
        
        if machines:
            ok = machines.filter(fact__fact_name='smart_status', fact__fact_data='Verified').count()
            warnings = machines.filter(fact__fact_name='smart_status', fact__fact_data='Not Supported').count()
            errors = machines.filter(fact__fact_name='smart_status', fact__fact_data='Failing').count()
        else:
            ok = None
            warnings = None
            errors = None

        c = Context({
            'title': 'SMART Status',
            'ok': ok,
            'warnings': warnings,
            'errors': errors,
            'page': page,
            'theid': theid
        })
        return t.render(c), 4
        
    def filter_machines(self, machines, data):
        if data == 'ok':
            machines = machines.filter(fact__fact_name='smart_status', fact__fact_data='Verified')
            title = 'Machines with Verified S.M.A.R.T. status'

        elif data == 'warnings':
            machines = machines.filter(fact__fact_name='smart_status', fact__fact_data='Not Supported')
            title = 'Machines with Not Supported S.M.A.R.T. status'

        elif data == 'errors':
            machines = machines.filter(fact__fact_name='smart_status', fact__fact_data='Failing')
            title = 'Machines with Failing S.M.A.R.T. status'

        else:
            machines = None
            title = 'Unknown'

        return machines, title
