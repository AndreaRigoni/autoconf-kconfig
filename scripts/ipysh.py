
import os
import cProfile, pstats
class Bootstrap_support():
    
    @staticmethod
    def autoreload(modules=None, env='IPY_AIMPORT'):
        '''
        Set Autoreload of modules that are defined in IPY_AIMPORT env variable
        This works for IPython 3.x or higher
        '''
        try:
            import os, importlib
            import IPython.core
            ipy = IPython.core.getipython.get_ipython()
            ipy.magic("load_ext autoreload")
            ipy.magic("autoreload 1")
        except:
            print('could not load requred modules')
            pass
        if modules is None:
            try: modules = os.environ.get(env).split(" ")
            except: modules = []
        for m in modules:
            try:
                # if m is not '__main__':
                #     importlib.import_module(m)
                ipy.magic('aimport %s'%m)
                print('reload set for module ',m)
            except:
                pass
        return ipy


    @staticmethod
    def debug(wait=False):
        try:
            import ptvsd
            # Allow other computers to attach to ptvsd at this IP address and port.
            ptvsd.enable_attach(address=('*', 3000), redirect_output=True)
            # Pause the program until a remote debugger is attached
            if wait:
                ptvsd.wait_for_attach()
            print('debug active on *:3000')
        except:
            print('unable to set vs debugger')


    def __init__(self):
        self._profile = cProfile.Profile()        
        pass



# import tensorflow as tf
# from tensorflow.python.client import timeline
#
# a = tf.random_normal([2000, 5000])
# b = tf.random_normal([5000, 1000])
# res = tf.matmul(a, b)

# with tf.Session() as sess:
#     # add additional options to trace the session execution
#     options = tf.RunOptions(trace_level=tf.RunOptions.FULL_TRACE)
#     run_metadata = tf.RunMetadata()
#     sess.run(res, options=options, run_metadata=run_metadata)

#     # Create the Timeline object, and write it to a json file
#     fetched_timeline = timeline.Timeline(run_metadata.step_stats)
#     chrome_trace = fetched_timeline.generate_chrome_trace_format()
#     with open('timeline_01.json', 'w') as f:
#         f.write(chrome_trace)



# pr = cProfile.Profile()
# pr.enable()
# # ... do something ...
# pr.disable()
# s = StringIO.StringIO()
# sortby = 'cumulative'
# ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
# ps.print_stats()
# print s.getvalue()


abs_srcdir   = os.environ.get('abs_srcdir')
abs_builddir = os.environ.get('abs_builddir')


# trigger autoreload functionality
Bootstrap_support.autoreload()

# trigger debug session
# Bootstrap_support.debug()



