/* global gl, Flash */
/* eslint-disable no-param-reassign */

((gl) => {
  gl.PipelineStore = class {
    fetchDataLoop(Vue, pageNum, url) {
      const setVueResources = () => { Vue.activeResources = 1; };
      const resetVueResources = () => { Vue.activeResources = 0; };
      const addToVueResources = () => { Vue.activeResources += 1; };
      const subtractFromVueResources = () => { Vue.activeResources -= 1; };

      resetVueResources();

      const updatePipelineNums = (count) => {
        const { all } = count;
        const running = count.running_or_pending;
        document.querySelector('.js-totalbuilds-count').innerHTML = all;
        document.querySelector('.js-running-count').innerHTML = running;
      };

      const resourceChecker = () => {
        if (Vue.activeResources === 0) {
          setVueResources();
        } else {
          addToVueResources();
        }
      };

      const goFetch = () =>
        this.$http.get(`${url}?page=${pageNum}`)
          .then((response) => {
            const res = JSON.parse(response.body);
            Vue.set(this, 'updatedAt', res.updated_at);
            Vue.set(this, 'pipelines', res.pipelines);
            Vue.set(this, 'count', res.count);
            updatePipelineNums(this.count);
            this.pageRequest = false;
            subtractFromVueResources();
          }, () => new Flash(
            'Something went wrong on our end.',
          ));

      resourceChecker();
      goFetch();

      const removePipelineIntervals = () => {
        this.allTimeIntervals.forEach(e => clearInterval(e.id));
      };

      const startIntervalLoops = () => {
        this.allTimeIntervals.forEach(e => e.start());
      };

      const removeAll = () => {
        removePipelineIntervals();
        window.removeEventListener('beforeunload', () => {});
        window.removeEventListener('focus', () => {});
        window.removeEventListener('blur', () => {});
        document.removeEventListener('page:fetch', () => {});
      };

      window.addEventListener('beforeunload', removePipelineIntervals);
      window.addEventListener('focus', startIntervalLoops);
      window.addEventListener('blur', removePipelineIntervals);
      document.addEventListener('page:fetch', removeAll);
    }
  };
})(window.gl || (window.gl = {}));
